class TicketSize {
  final double width;
  final double height;

  const TicketSize(this.width, this.height);

  TicketSize operator *(double scale) => TicketSize(
    width * scale,
    height * scale,
  );
}
