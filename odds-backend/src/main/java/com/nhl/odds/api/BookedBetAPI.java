package com.nhl.odds.api;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.nhl.odds.dto.BookedBetDTO;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.service.BookedBetService;


@RestController
@CrossOrigin
@RequestMapping(value = "/api")
public class BookedBetAPI {
	
	@Autowired
	BookedBetService bookedBetService;
	
	@PostMapping(value = "/bookBet")
	public ResponseEntity<String> bookBet(@RequestBody BookedBetDTO bookBet) throws OddsException {
		bookedBetService.bookBet(bookBet);
		return new ResponseEntity<String>("Bet successfully booked", HttpStatus.OK);
	}
	
	@PutMapping(value = "/updateBet")
	public ResponseEntity<String> updateBet(@RequestBody BookedBetDTO updateBet) throws OddsException {
		bookedBetService.updateBookedBet(updateBet);
		return new ResponseEntity<String>("Bet successfully updated", HttpStatus.OK);
	}
	
	@DeleteMapping(value = "/deleteBet")
	public ResponseEntity<String> deleteBet(@RequestBody BookedBetDTO deleteBet) throws OddsException {
		bookedBetService.deleteBookedBet(deleteBet);
		return new ResponseEntity<String>("Bet successfully deleted", HttpStatus.OK);
	}
	
	@GetMapping(value = "/getUserBets")
	public ResponseEntity<List<BookedBetDTO>> getUserBets(@RequestParam String username) throws OddsException {
		List<BookedBetDTO> bookedBets = bookedBetService.getBookedBetsByUser(username);
		return new ResponseEntity<List<BookedBetDTO>>(bookedBets, HttpStatus.OK);
	}
	
	@GetMapping(value = "/getUserBetsByDateRange")
	public ResponseEntity<List<BookedBetDTO>> getUserBetsDateRange(@RequestParam String username, @RequestParam String startTime, @RequestParam String endTime) throws OddsException{
		List<BookedBetDTO> bookedBets = bookedBetService.getBookedBetsByUserAndDateRange(username, Timestamp.valueOf(startTime), Timestamp.valueOf(endTime));
		return new ResponseEntity<List<BookedBetDTO>>(bookedBets, HttpStatus.OK);
	}
	
	
	
}
