import { IsNotEmpty, IsInt, Min } from 'class-validator';

export class ProcessPredictionDto {
  @IsNotEmpty()
  @IsInt()
  @Min(0)
  homeScore: number;

  @IsNotEmpty()
  @IsInt()
  @Min(0)
  awayScore: number;
}
