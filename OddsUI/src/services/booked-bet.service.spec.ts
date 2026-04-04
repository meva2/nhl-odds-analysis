import { TestBed } from '@angular/core/testing';

import { BookedBetService } from './booked-bet.service';

describe('BookedBetService', () => {
  let service: BookedBetService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(BookedBetService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
