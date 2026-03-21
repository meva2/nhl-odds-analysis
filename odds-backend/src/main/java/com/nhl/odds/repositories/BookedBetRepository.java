package com.nhl.odds.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.repository.CrudRepository;

import com.nhl.odds.entities.BookedBet;
import com.nhl.odds.entities.BookedBetId;

public interface BookedBetRepository extends CrudRepository<BookedBet, BookedBetId>{
	List<BookedBet> findByStartTimeUTCBetween(LocalDate startDate, LocalDate endDate);
	List<BookedBet> findAllByUsername(String username);
}
