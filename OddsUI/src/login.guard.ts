import { CanActivateFn, UrlTree, Router } from '@angular/router';
import { LoginService } from './services/login.service';
import { inject } from '@angular/core';

export const loginGuard: CanActivateFn = (): boolean | UrlTree => {
  const loginService = inject(LoginService);
  const router = inject(Router);
  if(loginService.isLoggedIn()){
    return true;
  }
  else {
    return router.createUrlTree(['/login'])
  }
};
