import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CurrentBetsComponent } from './current-bets.component';

describe('CurrentBetsComponent', () => {
  let component: CurrentBetsComponent;
  let fixture: ComponentFixture<CurrentBetsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CurrentBetsComponent]
    });
    fixture = TestBed.createComponent(CurrentBetsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
