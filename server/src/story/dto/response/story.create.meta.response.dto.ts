import { ApiProperty } from '@nestjs/swagger';

export class CreateStoryMetaResponseDto {
  @ApiProperty({ example: `[ { categoryId: 10, categoryName: '카페' }, ]`, description: '카테고리 리스트' })
  categories: { categoryId: number; categoryName: string }[];

  @ApiProperty({ example: `[ { badgeId: 3; badgeName: '카페인 중독' }, ]`, description: '뱃지 리스트' })
  badges: { badgeId: number; badgeName: string }[];
}

export class CreateStoryMetaResponseJSONDto {
  @ApiProperty({ description: '메타 데이터 (카테고리, 뱃지)', type: CreateStoryMetaResponseDto })
  meta: CreateStoryMetaResponseDto;
}
