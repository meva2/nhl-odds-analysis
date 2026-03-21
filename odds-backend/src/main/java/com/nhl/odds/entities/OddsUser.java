package com.nhl.odds.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Table(name="odds_user")
@Entity
@Data
public class OddsUser {
	@Id
	private String username;
	private String pw;
}
