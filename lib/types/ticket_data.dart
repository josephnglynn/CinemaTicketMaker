class TicketData {
  final String movieName;
  final String cinemaName;
  final String cinemaNameShort;
  final DateTime date;
  int participants;

  TicketData(this.movieName, this.participants, this.cinemaName,
      this.cinemaNameShort, this.date);
}