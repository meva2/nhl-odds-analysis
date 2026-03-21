package com.nhl.odds.service;


import com.nhl.odds.dto.OddsUserDTO;
import com.nhl.odds.exception.OddsException;

public interface UserService {
	public void registerUser(OddsUserDTO userDTO) throws OddsException;
	public String userLogin(OddsUserDTO userDTO) throws OddsException;
}
