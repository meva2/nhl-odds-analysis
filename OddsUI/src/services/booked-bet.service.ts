import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';


export interface BookedBet{
  username: string;
  startTimeUTC: Date;
  homeTeam: string;
  awayTeam: string;
  site: string;
  total: number;
  overPrice: number;
  underPrice: number;
  overPriority: number;
  underPriority: number;
  side: string;
  dollarAmount: number;
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

  getBookedBets(username: string): Observable<BookedBet[]>{
    const params = {"username": username};
    return this.http.get<any>(this.baseUrl+'/getUserBets', {params: params});
  }

  updateBet(bookedBet: BookedBet): Observable<string>{
    return this.http.put<string>(this.baseUrl+'/updateBet', bookedBet, {responseType: 'text' as 'json'});
  }

  deleteBet(bookedBet: BookedBet): Observable<string>{
    const headers = new HttpHeaders({
      'Content-Type': 'application/json'
    });
    const options = {
      body: bookedBet,
      headers: headers,
      responseType: 'text' as 'json'
    }
    return this.http.delete<string>(this.baseUrl+'/deleteBet', options);
  }
}
