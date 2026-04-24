package com.nhl.odds.repositories;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.nhl.odds.entities.BookedBet;
import com.nhl.odds.entities.BookedBetId;

public interface BookedBetRepository extends CrudRepository<BookedBet, BookedBetId>{

	List<BookedBet> findAllByUsername(String username);
	
	@Query("SELECT b FROM BookedBet b "
			+ "WHERE b.username = :username "
			+ "AND b.startTimeUTC >= :startDate "
			+ "AND b.startTimeUTC <= :endDate")
	List<BookedBet> findByUsernameAndDateRange(
			@Param("username") String username,
			@Param("startDate") Timestamp startDate,
			@Param("endDate") Timestamp endDate
	);
	
}
