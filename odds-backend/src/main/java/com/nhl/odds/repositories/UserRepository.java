package com.nhl.odds.repositories;

import java.util.Optional;

import org.springframework.data.repository.CrudRepository;

import com.nhl.odds.entities.OddsUser;

public interface UserRepository extends CrudRepository<OddsUser, Long>{
	public Optional<OddsUser> findOneByUsername(String username);
}
