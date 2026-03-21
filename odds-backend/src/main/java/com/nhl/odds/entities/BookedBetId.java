package com.nhl.odds.entities;

import java.io.Serializable;
import java.sql.Timestamp;

import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BookedBetId implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String username;
	@Column(name = "start_time_utc")
	private Timestamp startTimeUTC;
	private String homeTeam;
	private String awayTeam;
	private String site;
	

}
