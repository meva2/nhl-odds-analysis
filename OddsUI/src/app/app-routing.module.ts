import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { loginGuard } from 'src/login.guard';
import { LoginComponent } from './login/login.component';
import { CurrentBetsComponent } from './current-bets/current-bets.component';
import { ViewEditBetsComponent } from './view-edit-bets/view-edit-bets.component';

const routes: Routes = [
  
  {path: 'login', component: LoginComponent},
  {path: '', redirectTo: '/login', pathMatch: 'full'},
  {path: 'home', component: CurrentBetsComponent, canActivate: [loginGuard]},
  {path: 'mybets', component: ViewEditBetsComponent, canActivate: [loginGuard]}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
