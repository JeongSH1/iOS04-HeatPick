import { Inject, Injectable } from '@nestjs/common';
import { Story } from '../entities/story.entity';
import { StoryJasoTrie } from 'src/search/trie/storyTrie';
import { graphemeSeperation } from 'src/util/util.graphmeModify';
import { createStoryEntity } from '../util/util.create.story.entity';
import { Cron, CronExpression } from '@nestjs/schedule';
import { LocationDTO } from 'src/place/dto/location.dto';
import { calculateDistance } from 'src/util/util.haversine';
import { User } from '../entities/user.entity';
import { getStoryDetailPlaceDataResponseDto, StoryDetailPlaceDataResponseDto } from './dto/response/detail/story.detail.place.data.response.dto';
import { Badge } from '../entities/badge.entity';
import { Place } from '../entities/place.entity';
import { storyEntityToObjWithOneImg } from 'src/util/story.entity.to.obj';
import { Category } from '../entities/category.entity';
import { UserService } from 'src/user/user.service';
import { updateStory } from '../util/util.story.update';
import { In, Repository } from 'typeorm';
import { getStoryDetailStoryDataResponseDto, StoryDetailStoryDataResponseDto } from './dto/response/detail/story.detail.story.data.response';
import { getStoryDetailUserDataResponseDto, StoryDetailUserDataResponseDto } from './dto/response/detail/story.detail.user.data.response';
import { CreateStoryMetaResponseDto } from './dto/response/story.create.meta.response.dto';
import { getStoryDetailViewDataResponseJSONDto, StoryDetailViewDataResponseJSONDto } from './dto/response/detail/story.detail.view.data.response.dto';
import { StoryResultDto } from '../search/dto/response/story.result.dto';

@Injectable()
export class StoryService {
  private searchStoryResultCache = {};
  private recommendStoryCache = [];
  constructor(
    @Inject('STORY_REPOSITORY')
    private storyRepository: Repository<Story>,
    @Inject('USER_REPOSITORY')
    private userRepository: Repository<User>,
    @Inject('CATEGORY_REPOSITORY')
    private categoryRepository: Repository<Category>,
    private storyTitleJasoTrie: StoryJasoTrie,
    private userService: UserService,
  ) {
    this.loadSearchHistoryTrie();
  }

  @Cron(CronExpression.EVERY_HOUR)
  async loadSearchHistoryTrie() {
    this.recommendStoryCache = [];
    this.searchStoryResultCache = {};
    this.storyRepository.find({ relations: ['user'] }).then((everyStory) => {
      everyStory.forEach((story) => this.storyTitleJasoTrie.insert(graphemeSeperation(story.title), story.storyId));
    });
  }

  public async createMetaData(userId: number): Promise<CreateStoryMetaResponseDto> {
    const user: User = await this.userRepository.findOne({ where: { userId: userId }, relations: ['badges'] });
    const categoryList = await this.categoryRepository.find();
    const metaData: CreateStoryMetaResponseDto = {
      badges: (await user.badges).map((badge: Badge) => {
        return { badgeId: badge.badgeId, badgeName: badge.badgeName };
      }),
      categories: categoryList,
    };
    return metaData;
  }

  public async create(userId: string, { title, content, categoryId, place, images, badgeId, date }): Promise<number> {
    const user: User = await this.userRepository.findOne({ where: { oauthId: userId }, relations: ['badges'] });
    const badge: Badge = (await user.badges).filter((badge: Badge) => badge.badgeId === badgeId)[0];
    const category: Category = await this.categoryRepository.findOneBy({ categoryId: categoryId });
    const story: Story = await createStoryEntity({ title, content, category, place, images, badge, date });
    user.stories = Promise.resolve([...(await user.stories), story]);
    await this.userRepository.save(user);
    if (badge) await this.userService.addBadgeExp({ badgeName: badge.badgeName, userId: user.userId, exp: 10 });
    return story.storyId;
  }

  public async read(userId: number, storyId: number): Promise<StoryDetailViewDataResponseJSONDto> {
    const story: Story = await this.storyRepository.findOne({ where: { storyId: storyId }, relations: ['category', 'user', 'storyImages', 'user.profileImage', 'badge', 'usersWhoLiked', 'user.followers'] });
    const place: Place = await story.place;

    const storyDetailPlaceData: StoryDetailPlaceDataResponseDto = getStoryDetailPlaceDataResponseDto(place);
    const storyDetailStoryData: StoryDetailStoryDataResponseDto = await getStoryDetailStoryDataResponseDto(story, userId, storyDetailPlaceData);

    const user = await story.user;
    const storyDetailUserData: StoryDetailUserDataResponseDto = await getStoryDetailUserDataResponseDto(user, userId);

    return getStoryDetailViewDataResponseJSONDto(storyDetailStoryData, storyDetailUserData);
  }

  public async update(userId: string, { storyId, title, content, categoryId, place, images, badgeId, date }): Promise<number> {
    const user: User = await this.userRepository.findOne({ where: { oauthId: userId } });
    const story: Story = await this.storyRepository.findOne({ where: { storyId: storyId }, relations: ['storyImages', 'category', 'badge', 'place'] });
    const badge: Badge = (await user.badges).filter((badge: Badge) => badge.badgeId === badgeId)[0];
    const category: Category = await this.categoryRepository.findOneBy({ categoryId: categoryId });

    const updatedStory = await updateStory(story, { title, content, category, place, images, badge, date });

    await this.storyRepository.save(updatedStory);

    return story.storyId;
  }

  public async delete(userId: string, storyId: number): Promise<void> {
    const user: User = await this.userRepository.findOne({ where: { oauthId: userId } });
    user.stories = Promise.resolve((await user.stories).filter((story) => story.storyId !== storyId));
    await this.userRepository.save(user);
  }

  async getStoriesFromTrie(searchText: string, offset: number, limit: number): Promise<Story[]> {
    if (!this.searchStoryResultCache.hasOwnProperty(searchText)) {
      const seperatedStatement = graphemeSeperation(searchText);
      const ids = this.storyTitleJasoTrie.search(seperatedStatement, 100);
      const stories = await this.storyRepository.find({
        where: {
          storyId: In(ids),
        },
        relations: ['category', 'user'],
      });
      this.searchStoryResultCache[searchText] = stories;
    }

    const results = this.searchStoryResultCache[searchText];
    return results.slice(offset * limit, offset * limit + limit);
  }

  public async like(userId: number, storyId: number): Promise<number> {
    const story = await this.storyRepository.findOne({ where: { storyId: storyId } });
    const user = await this.userRepository.findOne({ where: { userId: userId }, relations: ['likedStories'] });

    story.likeCount += 1;
    (await user.likedStories).push(story);

    await this.storyRepository.save(story);
    await this.userRepository.save(user);

    const updatedStory = await this.storyRepository.findOne({ where: { storyId: storyId } });

    return updatedStory.likeCount;
  }

  public async unlike(userId: number, storyId: number): Promise<number> {
    const story = await this.storyRepository.findOne({ where: { storyId: storyId } });
    const user = await this.userRepository.findOne({ where: { userId: userId }, relations: ['likedStories'] });

    story.likeCount <= 0 ? (story.likeCount = 0) : (story.likeCount -= 1);
    user.likedStories = Promise.resolve((await user.likedStories).filter((story) => story.storyId !== storyId));
    await this.storyRepository.save(story);
    await this.userRepository.save(user);

    const updatedStory = await this.storyRepository.findOne({ where: { storyId: storyId } });

    return updatedStory.likeCount;
  }

  async getRecommendByLocationStory(locationDto: LocationDTO, offset: number, limit: number): Promise<StoryResultDto[]> {
    const stories = await this.storyRepository.find({ relations: ['user', 'category'] });

    const userLatitude = locationDto.latitude;
    const userLongitude = locationDto.longitude;

    const radius = 2;

    const results = await Promise.all(
      stories.map(async (story) => {
        const place = await story.place;

        if (place) {
          const placeDistance = calculateDistance(userLatitude, userLongitude, place.latitude, place.longitude);
          return placeDistance <= radius ? story : null;
        }
        return null;
      }),
    );

    const transformedStoryArr = results.filter((result) => result !== null);

    const storyArr = await Promise.all(
      transformedStoryArr.map(async (story) => {
        return storyEntityToObjWithOneImg(story);
      }),
    );
    return storyArr.slice(offset * limit, offset * limit + limit);
  }

  async getRecommendedStory(offset: number, limit: number): Promise<any[]> {
    try {
      if (this.recommendStoryCache.length <= 0) {
        const stories = await this.storyRepository.find({
          order: {
            likeCount: 'DESC',
          },
          relations: ['user', 'user.profileImage', 'storyImages', 'category'],
        });

        const storyArr = await Promise.all(
          stories.map(async (story) => {
            return storyEntityToObjWithOneImg(story);
          }),
        );

        this.recommendStoryCache = storyArr;
      }

      return this.recommendStoryCache.slice(offset * limit, offset * limit + limit);
    } catch (error) {
      throw error;
    }
  }

  async getFollowStories(userId: number, sortOption: number = 0, offset: number = 0, limit: number = 5): Promise<StoryResultDto[]> {
    const user = await this.userRepository.findOne({ where: { userId: userId }, relations: ['following', 'profileImage'] });
    const followings = user.following;

    const storyPromises = followings.map(async (following) => {
      const stories = await following.stories;
      return stories;
    });

    const allStories = await Promise.all(storyPromises);

    const flattenedStories = allStories.flat();

    const sortedStories = this.sortByOption(flattenedStories, sortOption);

    const storyObjectsPromises = sortedStories.map(async (story) => await storyEntityToObjWithOneImg(story));
    const storyObjects = await Promise.all(storyObjectsPromises);

    return storyObjects.slice(offset * limit, offset * limit + limit);
  }

  private sortByOption(stories: Story[], sortOption: number = 0): Story[] {
    if (sortOption == 0) {
      const sortByCreateDate = (a: Story, b: Story) => new Date(a.createAt).getTime() - new Date(b.createAt).getTime();
      const storiesSortedByCreateDate = [...stories].sort(sortByCreateDate);
      return storiesSortedByCreateDate;
    } else if (sortOption == 1) {
      const sortByLikeCount = (a: Story, b: Story) => b.likeCount - a.likeCount;
      const storiesSortedByLikeCount = [...stories].sort(sortByLikeCount);
      return storiesSortedByLikeCount;
    } else {
      const sortByCommentCount = (a: Story, b: Story) => b.commentCount - a.commentCount;
      const storiesSortedByCommentCount = [...stories].sort(sortByCommentCount);
      return storiesSortedByCommentCount;
    }
  }
}
