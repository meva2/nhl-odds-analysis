import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ViewEditBetsComponent } from './view-edit-bets.component';

describe('ViewEditBetsComponent', () => {
  let component: ViewEditBetsComponent;
  let fixture: ComponentFixture<ViewEditBetsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ViewEditBetsComponent]
    });
    fixture = TestBed.createComponent(ViewEditBetsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
