import { Inject, Injectable } from '@nestjs/common';
import { In, Repository } from 'typeorm';
import { Story } from 'src/entities/story.entity';

@Injectable()
export class StoryRepository {
  constructor(
    @Inject('STORY_REPOSITORY')
    private storyRepository: Repository<Story>,
  ) {}

  addStory(story: Story): Promise<Story> {
    return this.storyRepository.save(story);
  }
  findById(storyId: number): Promise<Story> {
    return this.storyRepository.findOne({ where: { storyId: storyId }, relations: ['user'] });
  }

  loadEveryStory() {
    return this.storyRepository.find();
  }

  async getStoriesByIds(ids: number[]) {
    return await this.storyRepository.find({
      where: {
        storyId: In(ids),
      },
    });
  }
}
