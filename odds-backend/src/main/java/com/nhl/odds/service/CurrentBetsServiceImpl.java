package com.nhl.odds.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.nhl.odds.dto.CurrentBetsDTO;
import com.nhl.odds.entities.CurrentBets;
import com.nhl.odds.exception.OddsException;
import com.nhl.odds.repositories.CurrentBetsRepository;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class CurrentBetsServiceImpl implements CurrentBetsService{
	@Autowired
	private CurrentBetsRepository currentBetsRepository;
	
	@Override
	public List<CurrentBetsDTO> getAllCurrentBets() throws OddsException{
		Iterable<CurrentBets> currentBets = currentBetsRepository.findAll();
		List<CurrentBetsDTO> currentBetsDTOs = new ArrayList<CurrentBetsDTO>();
		currentBets.forEach(currentBet -> {
			CurrentBetsDTO currentBetDTO = new CurrentBetsDTO();
			currentBetDTO.setAwayTeam(currentBet.getAwayTeam());
			currentBetDTO.setHomeTeam(currentBet.getHomeTeam());
			currentBetDTO.setOverPrice(currentBet.getOverPrice());
			currentBetDTO.setOverPriority(currentBet.getOverPriority());
			currentBetDTO.setStartTimeUTC(currentBet.getStartTimeUTC());
			currentBetDTO.setTotal(currentBet.getTotal());
			currentBetDTO.setUnderPrice(currentBet.getUnderPrice());
			currentBetDTO.setUnderPriority(currentBet.getUnderPriority());
			currentBetsDTOs.add(currentBetDTO);
		});
		if (currentBetsDTOs.isEmpty()){
			throw new OddsException("No current bets found.", HttpStatus.NOT_FOUND);
		}
		return currentBetsDTOs;
	}
	
	

}
