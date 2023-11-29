import { Injectable } from '@nestjs/common';
import { createCommentEntity } from '../util/util.create.comment.entity';
import { StoryRepository } from '../story/story.repository';
import { UserRepository } from '../user/user.repository';
import { Story } from '../entities/story.entity';
import { User } from '../entities/user.entity';
import { CommentViewResponseDto } from './dto/response/comment.view.response.dto';
import { removeMillisecondsFromISOString } from '../util/util.date.format.to.ISO8601';
import { CommentRepository } from './comment.repository';

@Injectable()
export class CommentService {
  constructor(
    private storyRepository: StoryRepository,
    private userRepository: UserRepository,
    private commentRepository: CommentRepository,
  ) {}

  public async getMentionable({ storyId, userId }) {
    const mentionables: { userId: number; username: string }[] = [];
    const story: Story = await this.storyRepository.findOneByOption({ where: { storyId: storyId }, relations: ['user', 'comments', 'comments.user', 'comments.mentions'] });
    mentionables.push({ userId: story.user.userId, username: story.user.username });
    (await story.comments).forEach((comment) => {
      mentionables.push({ userId: comment.user.userId, username: comment.user.username });
    });

    const user: User = await this.userRepository.findOneByOption({ where: { userId: userId }, relations: ['following'] });
    user.following.forEach((user) => {
      mentionables.push({ userId: user.userId, username: user.username });
    });
    return Array.from(new Set(mentionables.map((user) => user.userId))).map((userId) => {
      return mentionables.find((user) => user.userId === userId);
    });
  }

  public async create({ storyId, userId, content, mentions }) {
    const story = await this.storyRepository.findOneByOption({ where: { storyId: storyId } });

    const mentionedUsers: User[] = await Promise.all(
      mentions.map(async (userId: number) => {
        return await this.userRepository.findOneByOption({ where: { userId: userId }, relations: ['mentions'] });
      }),
    );

    const user = await this.userRepository.findOneByUserId(userId);

    const comment = createCommentEntity(content, user, story);
    await this.commentRepository.save(comment);
    story.commentCount += 1;
    await this.storyRepository.saveStory(story);

    for (const mentionedUser of mentionedUsers) {
      mentionedUser.mentions = [...mentionedUser.mentions, comment];
      await this.userRepository.save(mentionedUser);
    }

    return comment.commentId;
  }

  public async read(storyId: number, userId: number) {
    const story = await this.storyRepository.findOneByOption({ where: { storyId: storyId }, relations: ['comments', 'comments.user', 'comments.mentions', 'comments.user.profileImage'] });
    const commentViewResponse: CommentViewResponseDto = {
      comments: await Promise.all(
        (await story.comments).map(async (comment) => {
          return {
            commentId: comment.commentId,
            userId: comment.user.userId,
            userProfileImageURL: comment.user.profileImage.imageUrl,
            username: comment.user.username,
            createdAt: removeMillisecondsFromISOString(comment.createdAt.toISOString()),
            mentions: comment.mentions.map((user) => {
              return { userId: user.userId, username: user.username };
            }),
            content: comment.content,
            status: comment.user.userId === userId ? 0 : 1,
          };
        }),
      ),
    };

    return commentViewResponse;
  }

  public async update({ storyId, userId, commentId, content, mentions }) {
    const story = await this.storyRepository.findById(storyId);

    const mentionedUsers: User[] = mentions.map(async (userId: number) => {
      await this.userRepository.findOneByUserId(userId);
    });

    const user = await this.userRepository.findOneByUserId(userId);

    const newComment = createCommentEntity(content, user, story);

    story.comments = Promise.resolve(
      (await story.comments).map((comment) => {
        if (comment.commentId === commentId) return newComment;
        return comment;
      }),
    );

    await this.storyRepository.addStory(story);
    return newComment.commentId;
  }

  public async delete({ storyId, commentId }) {
    const story = await this.storyRepository.findById(storyId);
    story.comments = Promise.resolve((await story.comments).filter((comment) => comment.commentId !== commentId));

    await this.storyRepository.addStory(story);
    return commentId;
  }
}
