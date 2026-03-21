package com.nhl.odds.service;

import java.util.List;

import com.nhl.odds.dto.BookedBetDTO;
import com.nhl.odds.exception.OddsException;

public interface BookedBetService {
	public List<BookedBetDTO> getBookedBetsByUser(String username) throws OddsException;
	public void bookBet(BookedBetDTO betDTO) throws OddsException;
	public void deleteBookedBet(BookedBetDTO betDTO) throws OddsException;
	public void updateBookedBet(BookedBetDTO betDTO) throws OddsException;
}
