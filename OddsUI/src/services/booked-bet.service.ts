import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';


export class BookedBet{
  username: string ='';
  startTimeUTC: string ='';
  homeTeam: string ='';
  awayTeam: string ='';
  site: string ='';
  total: number =0;
  overPrice: number =0;
  underPrice: number =0;
  overPriority: number =0;
  underPriority: number =0;
  side: string ='';
  dollarAmount: number =0

  constructor(
    username:string, 
    startTimeUTC:string, 
    homeTeam:string, 
    awayTeam:string, 
    site:string, 
    total:number, 
    overPrice:number, 
    underPrice:number, 
    overPriority:number,
    underPriority:number,
    side:string,
    dollarAmount:number
  ){}
}

@Injectable({
  providedIn: 'root'
})
export class BookedBetService {

  baseUrl: string = 'http://localhost:8080/api';

  constructor(private http: HttpClient) { }

  bookBet(bookedBet: BookedBet): Observable<string>{
    return this.http.post<string>(this.baseUrl+'/bookBet', bookedBet, {responseType: 'text' as 'json'});
  }
}
