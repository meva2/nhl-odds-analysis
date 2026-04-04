package com.nhl.odds.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.nhl.odds.dto.OddsUserDTO;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.service.UserService;

@RestController
@CrossOrigin
@RequestMapping(value="/api")
public class UserAPI {
	@Autowired
	private UserService userService;
	
	@PostMapping(value="/user/add")
	public ResponseEntity<String> registerUser(@RequestBody OddsUserDTO userDTO) throws OddsException{
		userService.registerUser(userDTO);
		String message = "Registration successful";
		return new ResponseEntity<String>(message, HttpStatus.OK);
	}
	
	@PostMapping(value = "/user/login")
	public ResponseEntity<String> userLogin(@RequestBody OddsUserDTO userDTO) throws OddsException{
		userService.userLogin(userDTO);
		return new ResponseEntity<String>(userDTO.getUsername(), HttpStatus.OK);
	}

}
