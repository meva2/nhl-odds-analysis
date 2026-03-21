from write_snowflake import WriteSnowflake


def main():
    snf = WriteSnowflake()
    # daily updated odds and game results load
    # snf.write_current_odds()
    snf.write_recent_results()

    # initial historic data load
    # snf.write_games()
    # snf.write_odds()


if __name__ == '__main__':
    main()
