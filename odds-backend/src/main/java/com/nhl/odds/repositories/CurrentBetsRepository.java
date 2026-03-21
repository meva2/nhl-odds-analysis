package com.nhl.odds.repositories;

import org.springframework.data.repository.CrudRepository;

import com.nhl.odds.entities.CurrentBets;

public interface CurrentBetsRepository extends CrudRepository<CurrentBets, CurrentBets>{
	
}
