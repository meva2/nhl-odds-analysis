package com.nhl.odds.service;

import java.util.List;

import com.nhl.odds.dto.CurrentBetsDTO;
import com.nhl.odds.exception.OddsException;

public interface CurrentBetsService {
	public List<CurrentBetsDTO> getAllCurrentBets() throws OddsException;
}
