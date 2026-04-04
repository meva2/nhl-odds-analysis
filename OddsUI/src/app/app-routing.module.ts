import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { loginGuard } from 'src/login.guard';
import { LoginComponent } from './login/login.component';
import { CurrentBetsComponent } from './current-bets/current-bets.component';

const routes: Routes = [
  
  {path: 'login', component: LoginComponent},
  {path: '', redirectTo: '/login', pathMatch: 'full'},
  {path: 'home', component: CurrentBetsComponent, canActivate: [loginGuard]}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
