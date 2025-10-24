class Virology {
  final int? id;
  final int patientId;
  final String date;
  final String? havIgm;
  final String? havIgG;
  final String? hbsAg;
  final String? hbsAb;
  final String? hbcIgM;
  final String? hbcIgG;
  final String? hbeAg;
  final String? hbeAb;
  final String? hcvAb;
  final String? hivAbI_II;
  final String? hbvDnaPcr;
  final String? hcvRnaPcr;
  final String createdAt;

  Virology({
    this.id,
    required this.patientId,
    required this.date,
    this.havIgm,
    this.havIgG,
    this.hbsAg,
    this.hbsAb,
    this.hbcIgM,
    this.hbcIgG,
    this.hbeAg,
    this.hbeAb,
    this.hcvAb,
    this.hivAbI_II,
    this.hbvDnaPcr,
    this.hcvRnaPcr,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'hav_igm': havIgm,
      'hav_igg': havIgG,
      'hbs_ag': hbsAg,
      'hbs_ab': hbsAb,
      'hbc_igm': hbcIgM,
      'hbc_igg': hbcIgG,
      'hbe_ag': hbeAg,
      'hbe_ab': hbeAb,
      'hcv_ab': hcvAb,
      'hiv_ab_i_ii': hivAbI_II,
      'hbv_dna_pcr': hbvDnaPcr,
      'hcv_rna_pcr': hcvRnaPcr,
      'created_at': createdAt,
    };
  }

  factory Virology.fromMap(Map<String, dynamic> map) {
    return Virology(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      havIgm: map['hav_igm'],
      havIgG: map['hav_igg'],
      hbsAg: map['hbs_ag'],
      hbsAb: map['hbs_ab'],
      hbcIgM: map['hbc_igm'],
      hbcIgG: map['hbc_igg'],
      hbeAg: map['hbe_ag'],
      hbeAb: map['hbe_ab'],
      hcvAb: map['hcv_ab'],
      hivAbI_II: map['hiv_ab_i_ii'],
      hbvDnaPcr: map['hbv_dna_pcr'],
      hcvRnaPcr: map['hcv_rna_pcr'],
      createdAt: map['created_at'],
    );
  }
}
