import { TestBed } from '@angular/core/testing';

import { CurrentBetsService } from './current-bets.service';

describe('CurrentBetsService', () => {
  let service: CurrentBetsService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CurrentBetsService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
