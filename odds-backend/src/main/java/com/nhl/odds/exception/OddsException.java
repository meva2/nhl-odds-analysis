package com.nhl.odds.exception;

import org.springframework.http.HttpStatus;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class OddsException extends Exception{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private HttpStatus httpStatus;
	private String reply;

	public OddsException(String reply, HttpStatus httpStatus) {
		this.reply = reply;
		this.httpStatus = httpStatus;
	}

}
