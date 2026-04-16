import { Component, OnInit } from '@angular/core';
import { CurrentBetsService, CurrentBet } from 'src/services/current-bets.service';
import { FormBuilder, FormGroup, FormArray, Validators } from '@angular/forms';
import { Observable } from 'rxjs'
import { BookedBetService, BookedBet } from 'src/services/booked-bet.service';

@Component({
  selector: 'app-current-bets',
  templateUrl: './current-bets.component.html',
  styleUrls: ['./current-bets.component.css']
})
export class CurrentBetsComponent implements OnInit {

  betForm!: FormGroup;
  sides = ['over', 'under'];
  sites = ["Play Alberta", "Pinnacle"]

  constructor(
    private currentBetsService: CurrentBetsService,
    private bookedBetService: BookedBetService,
    private fb: FormBuilder
  ){}

  ngOnInit(): void {
    this.betForm = this.fb.group({
      bets: this.fb.array([])
    });
    this.loadBets();
  }

  get betsArray(): FormArray{
    return this.betForm.controls['bets'] as FormArray;
  }

  createBetFormGroup(bet: CurrentBet): FormGroup {
    return this.fb.group({
      startTimeUTC: [{value: bet.startTimeUTC, disabled:true}],
      homeTeam: [{value: bet.homeTeam, disabled:true}],
      awayTeam: [{value: bet.awayTeam, disabled:true}],
      total: [{value: bet.total, disabled:true}],
      overPrice: [{value: bet.overPrice, disabled:true}],
      underPrice: [{value: bet.underPrice, disabled:true}],
      overPriority: [{value: bet.overPriority, disabled:true}],
      underPriority: [{value: bet.underPriority, disabled:true}],
      side: [''],
      amount: [''],
      actualOverOdds: [''],
      actualUnderOdds: [''],
      site: [''],
      clicked: [false],
      errorMessage: [''],
      successMessage: ['']
    });
  }
  submitRow(index: number): void{
    let row = this.betsArray.at(index) as FormGroup;
    row.patchValue({successMessage: ''});
    row.patchValue({ErrorMessage: ''});
    row.patchValue({clicked: true});
    let bookBet = {
      "username": localStorage.getItem('login') ?? '',
      "startTimeUTC": row.get('startTimeUTC')?.value,
      "homeTeam": row.get('homeTeam')?.value,
      "awayTeam": row.get('awayTeam')?.value,
      "site": row.get('site')?.value,
      "total": row.get('total')?.value,
      "overPrice": row.get('actualOverOdds')?.value,
      "underPrice": row.get('actualUnderOdds')?.value,
      "overPriority": row.get('overPriority')?.value,
      "underPriority": row.get('underPriority')?.value,
      "side": row.get('side')?.value,
      "dollarAmount": row.get('amount')?.value
    };
    if (bookBet["username"] === ''){
      row.patchValue({errorMessage: 'Invalid user. Log in again.'});
      row.patchValue({clicked: false});
      return;
    }
    this.bookedBetService.bookBet(bookBet).subscribe({
      next: (response: string) =>{
        row.patchValue({successMessage: 'Bet successfully booked.'});
        row.patchValue({clicked: false});
      },
      error: (err) => {
        row.patchValue({errorMessage: err['error']});
        row.patchValue({clicked: false});
        console.log(row.get('errorMessage')?.value);
        console.log(err['error']);
      }
    });
  }

  loadBets(): void{
    this.currentBetsService.getCurrentBets().subscribe({
      next: (currentBets: CurrentBet[]) => {
        currentBets.forEach(bet => {
          this.betsArray.push(this.createBetFormGroup(bet))
        });
      },
      error: (err) => {
        console.log(err);

      }
    })
  }

  track(index:number, item:any){
    return index;
  }

  checkErrorMessage(index: number): boolean{
    return !!this.betsArray.at(index).get('errorMessage')?.value;    
  }

  checkSuccessMessage(index: number): boolean{
    return !!this.betsArray.at(index).get('successMessage')?.value;    
  }
}
