package com.nhl.odds.dto;

import java.sql.Timestamp;

public class CurrentBetsDTO {
	private Timestamp startTimeUTC;
	private String homeTeam;
	private String awayTeam;
	private float total;
	private int overPrice;
	private int underPrice;
	private float overPriority;
	private float underPriority;
	public Timestamp getStartTimeUTC() {
		return startTimeUTC;
	}
	public void setStartTimeUTC(Timestamp startTimeUTC) {
		this.startTimeUTC = startTimeUTC;
	}
	public String getHomeTeam() {
		return homeTeam;
	}
	public void setHomeTeam(String homeTeam) {
		this.homeTeam = homeTeam;
	}
	public String getAwayTeam() {
		return awayTeam;
	}
	public void setAwayTeam(String awayTeam) {
		this.awayTeam = awayTeam;
	}
	public float getTotal() {
		return total;
	}
	public void setTotal(float total) {
		this.total = total;
	}
	public int getOverPrice() {
		return overPrice;
	}
	public void setOverPrice(int overPrice) {
		this.overPrice = overPrice;
	}
	public int getUnderPrice() {
		return underPrice;
	}
	public void setUnderPrice(int underPrice) {
		this.underPrice = underPrice;
	}
	public float getOverPriority() {
		return overPriority;
	}
	public void setOverPriority(float overPriority) {
		this.overPriority = overPriority;
	}
	public float getUnderPriority() {
		return underPriority;
	}
	public void setUnderPriority(float underPriority) {
		this.underPriority = underPriority;
	}
	
}
