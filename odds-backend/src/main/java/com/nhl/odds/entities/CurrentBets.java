package com.nhl.odds.entities;

import java.io.Serializable;
import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@SuppressWarnings("serial")
@Table(name = "current_bet_recommendations")
@Entity
@IdClass(CurrentBets.class)
public class CurrentBets implements Serializable{
	@Id
	@Column(name = "start_time_utc")
	private Timestamp startTimeUTC;
	@Id
	private String homeTeam;
	@Id
	private String awayTeam;
	@Id
	private float total;
	@Id
	private int overPrice;
	@Id
	private int underPrice;
	@Id
	private float overPriority;
	@Id
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
