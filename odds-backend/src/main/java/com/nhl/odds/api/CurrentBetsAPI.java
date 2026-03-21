package com.nhl.odds.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.nhl.odds.dto.CurrentBetsDTO;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.service.CurrentBetsService;


@RestController
@CrossOrigin
@RequestMapping(value="/api")
public class CurrentBetsAPI {
	
	@Autowired
	private CurrentBetsService currentBetsService;
	
	@GetMapping(value = "/currentBets")
	public ResponseEntity<List<CurrentBetsDTO>> getAllCurrentBets() throws OddsException {
		List<CurrentBetsDTO> currentBetsList = currentBetsService.getAllCurrentBets();
		return new ResponseEntity<>(currentBetsList, HttpStatus.OK);
	}

}
