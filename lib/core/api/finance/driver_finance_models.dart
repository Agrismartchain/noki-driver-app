class DriverCodSummaryDto {
  const DriverCodSummaryDto({
    required this.currencyCode,
    required this.toRemitAmount,
    required this.remittedAmount,
    required this.reconciledAmount,
    required this.toRemitCount,
    required this.totalDeclaredCount,
  });

  factory DriverCodSummaryDto.fromJson(Map<String, dynamic> json) {
    return DriverCodSummaryDto(
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      toRemitAmount: (json['toRemitAmount'] as String?) ?? '0',
      remittedAmount: (json['remittedAmount'] as String?) ?? '0',
      reconciledAmount: (json['reconciledAmount'] as String?) ?? '0',
      toRemitCount: (json['toRemitCount'] as num?)?.toInt() ?? 0,
      totalDeclaredCount: (json['totalDeclaredCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String currencyCode;
  final String toRemitAmount;
  final String remittedAmount;
  final String reconciledAmount;
  final int toRemitCount;
  final int totalDeclaredCount;
}

class DriverFinanceSummaryDto {
  const DriverFinanceSummaryDto({
    required this.driverActorId,
    required this.organizationId,
    required this.countryCode,
    required this.currencyCode,
    required this.availableAmount,
    required this.pendingPayoutAmount,
    required this.paidAmount,
    required this.onHoldAmount,
    required this.grossEarnedAmount,
    required this.receivableCommissionAmount,
    required this.paymentMethodStatus,
    this.defaultPaymentMethodId,
    this.defaultPaymentMethodType,
    this.defaultPaymentMethodMasked,
    required this.canRequestPayout,
    required this.missingRemunerationRuleServices,
    required this.codSummary,
    required this.generatedAt,
  });

  factory DriverFinanceSummaryDto.fromJson(Map<String, dynamic> json) {
    final codRaw = json['codSummary'] as Map<String, dynamic>? ?? const {};
    return DriverFinanceSummaryDto(
      driverActorId: (json['driverActorId'] as String?) ?? '',
      organizationId: (json['organizationId'] as String?) ?? '',
      countryCode: (json['countryCode'] as String?) ?? 'CG',
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      availableAmount: (json['availableAmount'] as String?) ?? '0',
      pendingPayoutAmount: (json['pendingPayoutAmount'] as String?) ?? '0',
      paidAmount: (json['paidAmount'] as String?) ?? '0',
      onHoldAmount: (json['onHoldAmount'] as String?) ?? '0',
      grossEarnedAmount: (json['grossEarnedAmount'] as String?) ?? '0',
      receivableCommissionAmount:
          (json['receivableCommissionAmount'] as String?) ?? '0',
      paymentMethodStatus: (json['paymentMethodStatus'] as String?) ?? 'NONE',
      defaultPaymentMethodId: json['defaultPaymentMethodId'] as String?,
      defaultPaymentMethodType: json['defaultPaymentMethodType'] as String?,
      defaultPaymentMethodMasked: json['defaultPaymentMethodMasked'] as String?,
      canRequestPayout: (json['canRequestPayout'] as bool?) ?? false,
      missingRemunerationRuleServices:
          (json['missingRemunerationRuleServices'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
      codSummary: DriverCodSummaryDto.fromJson(codRaw),
      generatedAt: (json['generatedAt'] as String?) ?? '',
    );
  }

  final String driverActorId;
  final String organizationId;
  final String countryCode;
  final String currencyCode;
  final String availableAmount;
  final String pendingPayoutAmount;
  final String paidAmount;
  final String onHoldAmount;
  final String grossEarnedAmount;
  final String receivableCommissionAmount;
  final String paymentMethodStatus;
  final String? defaultPaymentMethodId;
  final String? defaultPaymentMethodType;
  final String? defaultPaymentMethodMasked;
  final bool canRequestPayout;
  final List<String> missingRemunerationRuleServices;
  final DriverCodSummaryDto codSummary;
  final String generatedAt;
}

class DriverEarningItemDto {
  const DriverEarningItemDto({
    required this.id,
    required this.sourceDomain,
    required this.serviceCode,
    required this.sourceReferenceType,
    required this.sourceReferenceId,
    required this.direction,
    required this.nature,
    required this.status,
    required this.currencyCode,
    required this.originalAmount,
    required this.allocatedAmount,
    required this.settledAmount,
    required this.remainingAmount,
    this.grossAmount,
    this.paymentMethod,
    required this.createdAt,
    this.settledAt,
  });

  factory DriverEarningItemDto.fromJson(Map<String, dynamic> json) {
    return DriverEarningItemDto(
      id: (json['id'] as String?) ?? '',
      sourceDomain: (json['sourceDomain'] as String?) ?? '',
      serviceCode: (json['serviceCode'] as String?) ?? '',
      sourceReferenceType: (json['sourceReferenceType'] as String?) ?? '',
      sourceReferenceId: (json['sourceReferenceId'] as String?) ?? '',
      direction: (json['direction'] as String?) ?? 'PAYABLE',
      nature: (json['nature'] as String?) ?? 'SERVICE_FEE',
      status: (json['status'] as String?) ?? 'OPEN',
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      originalAmount: (json['originalAmount'] as String?) ?? '0',
      allocatedAmount: (json['allocatedAmount'] as String?) ?? '0',
      settledAmount: (json['settledAmount'] as String?) ?? '0',
      remainingAmount: (json['remainingAmount'] as String?) ?? '0',
      grossAmount: json['grossAmount'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: (json['createdAt'] as String?) ?? '',
      settledAt: json['settledAt'] as String?,
    );
  }

  final String id;
  final String sourceDomain;
  final String serviceCode;
  final String sourceReferenceType;
  final String sourceReferenceId;
  final String direction;
  final String nature;
  final String status;
  final String currencyCode;
  final String originalAmount;
  final String allocatedAmount;
  final String settledAmount;
  final String remainingAmount;
  final String? grossAmount;
  final String? paymentMethod;
  final String createdAt;
  final String? settledAt;
}

class DriverCodCollectionItemDto {
  const DriverCodCollectionItemDto({
    required this.id,
    required this.orderId,
    required this.deliveryShipmentId,
    required this.status,
    required this.currencyCode,
    required this.expectedAmount,
    required this.collectedAmount,
    required this.declaredAt,
    this.remittedAt,
    this.reconciledAt,
  });

  factory DriverCodCollectionItemDto.fromJson(Map<String, dynamic> json) {
    return DriverCodCollectionItemDto(
      id: (json['id'] as String?) ?? '',
      orderId: (json['orderId'] as String?) ?? '',
      deliveryShipmentId: (json['deliveryShipmentId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'DECLARED',
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      expectedAmount: (json['expectedAmount'] as String?) ?? '0',
      collectedAmount: (json['collectedAmount'] as String?) ?? '0',
      declaredAt: (json['declaredAt'] as String?) ?? '',
      remittedAt: json['remittedAt'] as String?,
      reconciledAt: json['reconciledAt'] as String?,
    );
  }

  final String id;
  final String orderId;
  final String deliveryShipmentId;
  final String status;
  final String currencyCode;
  final String expectedAmount;
  final String collectedAmount;
  final String declaredAt;
  final String? remittedAt;
  final String? reconciledAt;
}

class DriverPayoutBlockerDto {
  const DriverPayoutBlockerDto({required this.code, required this.message});

  factory DriverPayoutBlockerDto.fromJson(Map<String, dynamic> json) {
    return DriverPayoutBlockerDto(
      code: (json['code'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
    );
  }

  final String code;
  final String message;
}

class DriverPayoutEligibilityDto {
  const DriverPayoutEligibilityDto({
    required this.eligible,
    required this.currencyCode,
    required this.availableAmount,
    this.minimumAmount,
    this.maximumAmount,
    this.defaultPaymentMethodId,
    this.defaultPaymentMethodType,
    this.defaultPaymentMethodMasked,
    required this.eligibleObligationIds,
    required this.blockers,
    this.activePayoutRequestId,
  });

  factory DriverPayoutEligibilityDto.fromJson(Map<String, dynamic> json) {
    return DriverPayoutEligibilityDto(
      eligible: (json['eligible'] as bool?) ?? false,
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      availableAmount: (json['availableAmount'] as String?) ?? '0',
      minimumAmount: json['minimumAmount'] as String?,
      maximumAmount: json['maximumAmount'] as String?,
      defaultPaymentMethodId: json['defaultPaymentMethodId'] as String?,
      defaultPaymentMethodType: json['defaultPaymentMethodType'] as String?,
      defaultPaymentMethodMasked: json['defaultPaymentMethodMasked'] as String?,
      eligibleObligationIds:
          (json['eligibleObligationIds'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(growable: false),
      blockers: (json['blockers'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DriverPayoutBlockerDto.fromJson)
          .toList(growable: false),
      activePayoutRequestId: json['activePayoutRequestId'] as String?,
    );
  }

  final bool eligible;
  final String currencyCode;
  final String availableAmount;
  final String? minimumAmount;
  final String? maximumAmount;
  final String? defaultPaymentMethodId;
  final String? defaultPaymentMethodType;
  final String? defaultPaymentMethodMasked;
  final List<String> eligibleObligationIds;
  final List<DriverPayoutBlockerDto> blockers;
  final String? activePayoutRequestId;
}

class DriverPayoutItemDto {
  const DriverPayoutItemDto({
    required this.id,
    required this.code,
    required this.status,
    required this.currencyCode,
    required this.totalAmount,
    this.destinationMasked,
    this.paymentMethodType,
    required this.lineCount,
    required this.createdAt,
    this.firstApprovedAt,
    this.finalApprovedAt,
    this.sentAt,
    this.paidAt,
    this.cancelledAt,
    this.failureReason,
  });

  factory DriverPayoutItemDto.fromJson(Map<String, dynamic> json) {
    return DriverPayoutItemDto(
      id: (json['id'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'PENDING_FIRST_APPROVAL',
      currencyCode: (json['currencyCode'] as String?) ?? 'XAF',
      totalAmount: (json['totalAmount'] as String?) ?? '0',
      destinationMasked: json['destinationMasked'] as String?,
      paymentMethodType: json['paymentMethodType'] as String?,
      lineCount: (json['lineCount'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as String?) ?? '',
      firstApprovedAt: json['firstApprovedAt'] as String?,
      finalApprovedAt: json['finalApprovedAt'] as String?,
      sentAt: json['sentAt'] as String?,
      paidAt: json['paidAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      failureReason: json['failureReason'] as String?,
    );
  }

  final String id;
  final String code;
  final String status;
  final String currencyCode;
  final String totalAmount;
  final String? destinationMasked;
  final String? paymentMethodType;
  final int lineCount;
  final String createdAt;
  final String? firstApprovedAt;
  final String? finalApprovedAt;
  final String? sentAt;
  final String? paidAt;
  final String? cancelledAt;
  final String? failureReason;
}
