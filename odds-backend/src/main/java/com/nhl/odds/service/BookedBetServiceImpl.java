package com.nhl.odds.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.nhl.odds.dto.BookedBetDTO;
import com.nhl.odds.entities.BookedBet;
import com.nhl.odds.entities.BookedBetId;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.repositories.BookedBetRepository;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class BookedBetServiceImpl implements BookedBetService{
	
	@Autowired
	private BookedBetRepository bookedBetRepository;
	
	public void bookBet(BookedBetDTO betDTO) throws OddsException {
		BookedBetId betId = new BookedBetId(
				betDTO.getUsername(),
				betDTO.getStartTimeUTC(),
				betDTO.getHomeTeam(),
				betDTO.getAwayTeam(),
				betDTO.getSite()
				);
		Optional<BookedBet> optionalBet = bookedBetRepository.findById(betId);
		BookedBet bookedBet = optionalBet.orElse(null);
		if(bookedBet != null) {
			throw new OddsException("Bet already booked by user.", HttpStatus.CONFLICT);
		}
		else {
			BookedBet saveBet = new BookedBet();
			saveBet.setUsername(betDTO.getUsername());
			saveBet.setStartTimeUTC(betDTO.getStartTimeUTC());
			saveBet.setHomeTeam(betDTO.getHomeTeam());
			saveBet.setAwayTeam(betDTO.getAwayTeam());
			saveBet.setSite(betDTO.getSite());
			saveBet.setTotal(betDTO.getTotal());
			saveBet.setOverPrice(betDTO.getOverPrice());
			saveBet.setUnderPrice(betDTO.getUnderPrice());
			saveBet.setOverPriority(betDTO.getOverPriority());
			saveBet.setUnderPriority(betDTO.getUnderPriority());
			saveBet.setSide(betDTO.getSide());
			saveBet.setDollarAmount(betDTO.getDollarAmount());
			bookedBetRepository.save(saveBet);
		}
		
	}
	
	public List<BookedBetDTO> getBookedBetsByUser(String username) throws OddsException{
		List<BookedBetDTO> bookedBetsDTO = new ArrayList<BookedBetDTO>();
		List<BookedBet> bookedBets = bookedBetRepository.findAllByUsername(username);
		bookedBets.forEach(bookedBet -> {
			BookedBetDTO bookedBetDTO = new BookedBetDTO();
			bookedBetDTO.setUsername(username);
			bookedBetDTO.setStartTimeUTC(bookedBet.getStartTimeUTC());
			bookedBetDTO.setHomeTeam(bookedBet.getHomeTeam());
			bookedBetDTO.setAwayTeam(bookedBet.getAwayTeam());
			bookedBetDTO.setSite(bookedBet.getSite());
			bookedBetDTO.setTotal(bookedBet.getTotal());
			bookedBetDTO.setOverPrice(bookedBet.getOverPrice());
			bookedBetDTO.setUnderPrice(bookedBet.getUnderPrice());
			bookedBetDTO.setOverPriority(bookedBet.getOverPriority());
			bookedBetDTO.setUnderPriority(bookedBet.getUnderPriority());
			bookedBetDTO.setSide(bookedBet.getSide());
			bookedBetDTO.setDollarAmount(bookedBet.getDollarAmount());
			bookedBetsDTO.add(bookedBetDTO);
		});
		if (bookedBetsDTO.isEmpty()) {
			throw new OddsException("No bets found for user: " + username, HttpStatus.NOT_FOUND);
		}
		return bookedBetsDTO;
	}
	
	public void deleteBookedBet(BookedBetDTO betDTO) throws OddsException{
		BookedBetId betId = new BookedBetId(
				betDTO.getUsername(),
				betDTO.getStartTimeUTC(),
				betDTO.getHomeTeam(),
				betDTO.getAwayTeam(),
				betDTO.getSite()
				);
		System.out.println(betId.toString());
		Optional<BookedBet> optionalBet = bookedBetRepository.findById(betId);
		BookedBet bookedBet = optionalBet.orElse(null);
		if(bookedBet == null) {
			throw new OddsException("Bet already deleted or does not exist.", HttpStatus.NOT_FOUND);
		}
		bookedBetRepository.delete(bookedBet);
		
	}
	
	public void updateBookedBet(BookedBetDTO betDTO) throws OddsException{
		BookedBetId betId = new BookedBetId(
				betDTO.getUsername(),
				betDTO.getStartTimeUTC(),
				betDTO.getHomeTeam(),
				betDTO.getAwayTeam(),
				betDTO.getSite()
				);
		System.out.println(betDTO.getStartTimeUTC());
		System.out.println(betId.getStartTimeUTC());
		Optional<BookedBet> optionalBet = bookedBetRepository.findById(betId);
		BookedBet bookedBet = optionalBet.orElse(null);
		if(bookedBet == null) {
			throw new OddsException("Bet already deleted or does not exist.", HttpStatus.NOT_FOUND);
		}
		bookedBet.setTotal(betDTO.getTotal());
		bookedBet.setOverPrice(betDTO.getOverPrice());
		bookedBet.setUnderPrice(betDTO.getUnderPrice());
		bookedBet.setOverPriority(betDTO.getOverPriority());
		bookedBet.setUnderPriority(betDTO.getUnderPriority());
		bookedBet.setSide(betDTO.getSide());
		bookedBet.setDollarAmount(betDTO.getDollarAmount());
		bookedBetRepository.save(bookedBet);
		
	}

}
