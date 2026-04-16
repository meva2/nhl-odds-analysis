package com.nhl.odds.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.nhl.odds.dto.OddsUserDTO;
import com.nhl.odds.entities.OddsUser;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.repositories.UserRepository;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class UserServiceImpl implements UserService{
	@Autowired
	private UserRepository userRepository;
	
	@Override
	public void registerUser(OddsUserDTO userDTO) throws OddsException{
		Optional<OddsUser> optionalUser = userRepository.findOneByUsername(userDTO.getUsername());
		OddsUser existingUser = optionalUser.orElse(null);
		if (existingUser != null) {
			throw new OddsException("Username already exists.", HttpStatus.CONFLICT);
		}
		OddsUser newUser = new OddsUser();
		newUser.setPw(userDTO.getPw());
		newUser.setUsername(userDTO.getUsername());
		userRepository.save(newUser);
	}
	
	@Override
	public String userLogin(OddsUserDTO userDTO) throws OddsException{
		Optional<OddsUser> optionalUser = userRepository.findOneByUsername(userDTO.getUsername());
		OddsUser existingUser = optionalUser.orElse(null);
		if (existingUser == null) {
			throw new OddsException("Invalid credentials", HttpStatus.UNAUTHORIZED);
		}
		if (!existingUser.getPw().equals(userDTO.getPw())) {
			throw new OddsException("Invalid credentials", HttpStatus.UNAUTHORIZED);
		}	
		return userDTO.getUsername();
	}
}
