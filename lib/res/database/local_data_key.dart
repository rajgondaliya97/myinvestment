enum LocalDataKey {
  userData('user_data'),
  superAdminId('super_admin_id'),
  branchId('branch_id'),
  staffId('staff_id'),
  isLoggedIn('is_logged_in'),
  accessToken('access_token'),
  customerList('customer_list'),
  ticketListing('ticket_listing'),
  staffRoll('staff_roll'),
  localTicketList('local_ticket_list'),
  localTicketScanList('local_ticket_scan_list'),
  globalTimeSlots('global_time_slots'),
  dashBoardData('dash_board_data'),
  socksPrice('socks_price'),
  socksQuantity('socks_quantity'),
  promoCodeList('promoCodeList'),
  socksGstPer('socks_gst_per');

  final String key;
  const LocalDataKey(this.key);
}