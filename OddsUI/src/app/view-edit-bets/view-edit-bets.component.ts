import { Component } from '@angular/core';
import { FormArray, FormBuilder, FormGroup } from '@angular/forms';
import { BookedBet, BookedBetService } from 'src/services/booked-bet.service';
import { subHours } from 'date-fns'

@Component({
  selector: 'app-view-edit-bets',
  templateUrl: './view-edit-bets.component.html',
  styleUrls: ['./view-edit-bets.component.css']
})
export class ViewEditBetsComponent {

  betForm!: FormGroup;
  sides = ['over', 'under'];
  sites = ["Play Alberta", "Pinnacle"]

  constructor(
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

  createBetFormGroup(bet: BookedBet): FormGroup {
      return this.fb.group({
        startTimeUTC: [{value: bet.startTimeUTC, disabled:true}],
        homeTeam: [{value: bet.homeTeam, disabled:true}],
        awayTeam: [{value: bet.awayTeam, disabled:true}],
        total: [{value: bet.total, disabled:true}],
        overPrice: [{value: bet.overPrice, disabled:true}],
        underPrice: [{value: bet.underPrice, disabled:true}],
        overPriority: [{value: bet.overPriority, disabled:true}],
        underPriority: [{value: bet.underPriority, disabled:true}],
        side: [{value: bet.side, disabled:true}],
        amount: [{value: bet.dollarAmount, disabled:true}],
        site: [{value: bet.site, disabled:true}],
        clicked: [false],
        errorMessage: [''],
        successMessage: [''],
        editable: [false]
      });
    }

  loadBets(): void{
    this.bookedBetService.getBookedBets(localStorage.getItem('login') ?? '').subscribe({
      next: (bookedBets: BookedBet[]) => {
        bookedBets.forEach(bet => {
        this.betsArray.push(this.createBetFormGroup(bet))
      });
      console.log(bookedBets);
      },
      error: (err) => {
        console.log(err);
      }
    })
  }

  updateRow(index: number): void{
    let row = this.betsArray.at(index) as FormGroup;
    row.patchValue({successMessage: ''});
    row.patchValue({ErrorMessage: ''});
    row.patchValue({clicked: true});
    let updateBet = {
      "username": localStorage.getItem('login') ?? '',
      "startTimeUTC": subHours(new Date(row.get('startTimeUTC')?.value), 6),
      "homeTeam": row.get('homeTeam')?.value,
      "awayTeam": row.get('awayTeam')?.value,
      "site": row.get('site')?.value,
      "total": row.get('total')?.value,
      "overPrice": row.get('overPrice')?.value,
      "underPrice": row.get('underPrice')?.value,
      "overPriority": row.get('overPriority')?.value,
      "underPriority": row.get('underPriority')?.value,
      "side": row.get('side')?.value,
      "dollarAmount": row.get('amount')?.value
    };
    console.log()
    console.log(updateBet);
    if (updateBet["username"] === ''){
      row.patchValue({errorMessage: 'Invalid user. Log in again.'});
      row.patchValue({clicked: false});
      return;
    }
    this.bookedBetService.updateBet(updateBet).subscribe({
      next: (response: string) =>{
        row.patchValue({successMessage: 'Bet successfully updated'});
        row.patchValue({clicked: false});
        this.toggleEdit(index);
      },
      error: (err) => {
        row.patchValue({errorMessage: err['error']});
        row.patchValue({clicked: false});
        console.log(row.get('errorMessage')?.value);
        console.log(err['error']);
      }
    });
  }

  deleteRow(index: number): void {
    let row = this.betsArray.at(index) as FormGroup;
    row.patchValue({successMessage: ''});
    row.patchValue({ErrorMessage: ''});
    row.patchValue({clicked: true});
    let deleteBet = {
      "username": localStorage.getItem('login') ?? '',
      "startTimeUTC": subHours(new Date(row.get('startTimeUTC')?.value), 6),
      "homeTeam": row.get('homeTeam')?.value,
      "awayTeam": row.get('awayTeam')?.value,
      "site": row.get('site')?.value,
      "total": row.get('total')?.value,
      "overPrice": row.get('overPrice')?.value,
      "underPrice": row.get('underPrice')?.value,
      "overPriority": row.get('overPriority')?.value,
      "underPriority": row.get('underPriority')?.value,
      "side": row.get('side')?.value,
      "dollarAmount": row.get('amount')?.value
    };
    console.log(deleteBet);
    if (deleteBet["username"] === ''){
      row.patchValue({errorMessage: 'Invalid user. Log in again.'});
      row.patchValue({clicked: false});
      return;
    }
    this.bookedBetService.deleteBet(deleteBet).subscribe({
      next: (response: string) =>{
        this.betsArray.removeAt(index);
      },
      error: (err) => {
        row.patchValue({errorMessage: err['error']});
        row.patchValue({clicked: false});
        console.log(row.get('errorMessage')?.value);
        console.log(err['error']);
      }
    });
  }

  toggleEdit(index: number): void{
    let row = this.betsArray.at(index) as FormGroup;
    row.patchValue({clicked: !row.get('clicked')?.value});
    row.patchValue({editable: !row.get('editable')?.value});
    if(row.get('editable')?.value){
      row.get('overPrice')?.enable();
      row.get('underPrice')?.enable();
      row.get('side')?.enable();
      row.get('amount')?.enable();
    }
    else{
      row.get('overPrice')?.disable();
      row.get('underPrice')?.disable();
      row.get('side')?.disable();
      row.get('amount')?.disable();
    }
  }

  checkErrorMessage(index: number): boolean{
    return !!this.betsArray.at(index).get('errorMessage')?.value;    
  }

  checkSuccessMessage(index: number): boolean{
    return !!this.betsArray.at(index).get('successMessage')?.value;    
  }

  checkEditable(index: number): boolean{
    return this.betsArray.at(index).get('editable')?.value;
  }

}
