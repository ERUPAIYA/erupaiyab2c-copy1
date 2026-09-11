import '../../../constants/file_constants.dart';

String displayServiceName(String name) {
  if (name == 'Landline Postpaid') return 'Landline';
  if (name == 'Broadband Postpaid') return 'Broadband';
  return name;
}

String? localAssetForService(String name) {
  final n = name.trim().toLowerCase();

  if (n.contains('mobile prepaid')) return FileConstants.mobilePrepaidPng;
  if (n.contains('mobile postpaid')) return FileConstants.mobilePostpaidPng;
  if (n.contains('fastag') || n.contains('fast tag')) {
    return FileConstants.fastagPng;
  }
  if (n.contains('ev recharge') || n == 'ev') return FileConstants.evChargePng;
  if (n.contains('fleet')) return FileConstants.fleetCardPng;
  if (n.contains('ncmc')) return FileConstants.ncmcPng;

  if (n.contains('electric')) return FileConstants.electricity;
  if (n.contains('prepaid meter')) return FileConstants.prepaidMeter;
  if (n.contains('cable')) return FileConstants.cable;
  if (n.contains('dth')) return FileConstants.dth;
  if (n.contains('broadband')) return FileConstants.broadband;
  if (n.contains('landline')) return FileConstants.landline;
  if (n.contains('water')) return FileConstants.water;
  if (n.contains('piped gas') || n.contains('pipe gas')) {
    return FileConstants.pipegas;
  }
  if (n.contains('lpg') || n.contains('book gas')) {
    return FileConstants.gasCylinder;
  }
  if (n.contains('housing')) return FileConstants.housing;
  if (n.contains('municipal')) return FileConstants.municipal;

  if (n.contains('credit card')) return FileConstants.credit;
  if (n.contains('digital gold') || n == 'gold') return FileConstants.digitalGold;
  if (n.contains('digital silver') || n == 'silver') {
    return FileConstants.digitalSilverPng;
  }
  if (n.contains('loan')) return FileConstants.repayment;
  if (n.contains('echallan') || n.contains('e-challan') || n.contains('e challan')) {
    return FileConstants.eChalan;
  }
  if (n.contains('nps') || n.contains('pension')) return FileConstants.nps;
  if (n.contains('forex')) return FileConstants.forex;
  if (n.contains('agent collection') || n.contains('agent')) {
    return FileConstants.agentCollection;
  }

  if (n.contains('school fee')) return FileConstants.schoolFees;
  if (n.contains('college fee')) return FileConstants.collegeFees;
  if (n.contains('tuition') || n.contains('tution')) {
    return FileConstants.tutionFees;
  }
  if (n.contains('education')) return FileConstants.education;

  if (n.contains('general insurance') || n == 'general') {
    return FileConstants.generalInsurance;
  }
  if (n.contains('health')) return FileConstants.healthInsurance;
  if (n.contains('life')) return FileConstants.lifeInsurance;
  if (n.contains('insurance')) return FileConstants.insurance;

  if (n.contains('shop rent')) return FileConstants.shopRent;
  if (n.contains('house rent') || n.contains('rent')) {
    return FileConstants.houseRent;
  }

  return null;
}
