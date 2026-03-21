package com.nhl.odds.dto;

import java.sql.Timestamp;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class BookedBetDTO {
	private String username;
	private Timestamp startTimeUTC;
	private String homeTeam;
	private String awayTeam;
	private String site;
	private float total;
	private int overPrice;
	private int underPrice;
	private float overPriority;
	private float underPriority;
	private String side;
	private float dollarAmount;

}
