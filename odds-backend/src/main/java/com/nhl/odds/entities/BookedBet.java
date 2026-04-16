package com.nhl.odds.entities;



import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table
@Entity
@IdClass(BookedBetId.class)
@NoArgsConstructor
@Data
public class BookedBet {
	@Id
	private String username;
	@Id
	@Column(name = "start_time_utc")
	private Timestamp startTimeUTC;
	@Id
	private String homeTeam;
	@Id
	private String awayTeam;
	@Id
	private String site;
	private float total;
	private int overPrice;
	private int underPrice;
	private float overPriority;
	private float underPriority;
	private String side;
	private float dollarAmount;
}
