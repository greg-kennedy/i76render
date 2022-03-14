#!/usr/bin/env perl
use strict;
use warnings;

use autodie;

use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END);

# read N bytes from file and return
sub _rd
{
  my ($fp, $len) = @_;
  my $buffer;
  read $fp, $buffer, $len;
  return $buffer;
}

# read a UINT32
sub _r32
{
  return unpack 'V', _rd($_[0], 4);
}

open my $fp, '<:raw', $ARGV[0];
# search for ZONE, ZMAP or the magic map title string
my $ptr = 0;
my @zmap;
my $zone;
my $name;

# TODO: names of Original maps are hardcoded in the .exe and must be supplied here
my %arg2name = (
  'A01.MSN' => 'Training',
  'M01.MSN' => 'The Crater',
  'M02.MSN' => 'Dunes',
  'M03.MSN' => 'Air Base',
  'M04.MSN' => 'Suburbia',
  'M05.MSN' => 'Slick Track',
  'M06.MSN' => 'Tombstone',
  'M07.MSN' => 'Hope Springs',
  'M08.MSN' => 'Creeper Canyon',
  'M09.MSN' => 'Mesa Maze',
  'M10.MSN' => 'Salt Flats',
  'M11.MSN' => "Vigilante's Paradise",
  'M12.MSN' => 'Night Driver',
  'M13.MSN' => 'Dodge',
  'M14.MSN' => "Jorczak's Peak",
  'M15.MSN' => 'A Lot of Asphalt'
);
$name = $arg2name{$ARGV[0]};

# OBJECT LISTING WE MIGHT CARE ABOUT
my %obj = (
  SPAWN => [ 0, 0, 'Skip' ],
  '#SPAWN1' => [ 0, 0, 'Skip' ],
  '#SPAWN2' => [ 0, 0, 'Skip' ],
  '#SPAWN3' => [ 0, 0, 'Skip' ],
  '#SPAWN4' => [ 0, 0, 'Skip' ],
  REGEN => [ 0, 0, 'Skip' ],

  BCBANK1 => [ 22, 16, 'Struct' ],
  BCBANK2 => [ 22, 16, 'Struct' ],
  BCFIREW1 => [ 10, 5, 'Struct' ],
  BCGARAG1 => [ 30, 35, 'Struct' ],
  BCGARAG2 => [ 30, 35, 'Struct' ],
  BCGARAG3 => [ 30, 35, 'Struct' ],
  BCHOTEL1 => [ 12, 17, 'Struct' ],
  BCINDIA1 => [ 15, 10, 'Struct' ],
  BCINDIA2 => [ 15, 10, 'Struct' ],
  BCLIVRY1 => [ 12, 20, 'Struct' ],
  BCNOFCB3 => [ 31, 37, 'Struct' ],
  BCOFCB3 => [ 35, 36, 'Struct' ],
  BCPOST1 => [ 18, 21, 'Struct' ],
  BCPOST2 => [ 18, 21, 'Struct' ],
  BCTATTO1 => [ 15, 10, 'Struct' ],
  BCTATTO2 => [ 15, 10, 'Struct' ],
  BCWWHSE1 => [ 24, 42, 'Struct' ],
  BCWWHSE2 => [ 24, 42, 'Struct' ],
  BCXWHSE1 => [ 24, 41, 'Struct' ],
  BCXWHSE2 => [ 24, 41, 'Struct' ],
  BCXWHSE5 => [ 35, 41, 'Struct' ],
  BCYWHSE1 => [ 24, 41, 'Struct' ],
  BCYWHSE2 => [ 24, 41, 'Struct' ],
  BCYWHSE3 => [ 24, 41, 'Struct' ],
  BCYWHSE4 => [ 24, 41, 'Struct' ],
  BDBARD1 => [ 28, 23, 'Struct' ],
  BDFOXY1 => [ 50, 50, 'Struct' ],
  BDDONUT1 => [ 40, 30, 'Struct' ],
  BDMIGHT1 => [ 75, 60, 'Struct' ],
  BDMIGHT2 => [ 75, 60, 'Struct' ],
  BDSALOO1 => [ 10, 15, 'Struct' ],
  BDWGNWL1 => [ 70, 70, 'Struct' ],
  BDZFREZ1 => [ 70, 60, 'Struct' ],
  BDZFREZ2 => [ 70, 60, 'Struct' ],
  BCSTRAK3 => [ 20, 30, 'Struct' ],
  BFGASTF1 => [ 70, 50, 'Struct' ],
  BFNSPAN1 => [ 120, 75, 'Struct' ],
  BFPARAD1 => [ 110, 65, 'Struct' ],
  BFPARAD2 => [ 110, 65, 'Struct' ],
  BFSINCE1 => [ 60, 45, 'Struct' ],
  BFDEPOT1 => [ 30, 30, 'Struct' ],
  BFDEPOT2 => [ 30, 30, 'Struct' ],
  BFLGILA1 => [ 120, 75, 'Struct' ],
  BCSTRAK1 => [ 75, 30, 'Struct' ],
  BCSTRAK2 => [ 60, 30, 'Struct' ],
  BCSTRAK4 => [ 20, 5, 'Struct' ],
  BCSTRAK5 => [ 10, 7, 'Struct' ],
  BCSTRAK6 => [ 25, 5, 'Struct' ],
  BCSTRAK7 => [ 25, 5, 'Struct' ],
  BCSTRAK8 => [ 20, 2, 'Struct' ],
  BCSTRAK9 => [ 20, 2, 'Struct' ],
  BCSTRAK0 => [ 15, 5, 'Struct' ],
  BHBARN1 => [ 14, 27, 'Struct' ],
  BHBARN2 => [ 14, 27, 'Struct' ],
  BHTSLIP1 => [ 5, 10, 'Struct' ],
  BHGSGLW1 => [ 5, 15, 'Struct' ],
  BHGSGLW2 => [ 5, 15, 'Struct' ],
  BHHOUSE1 => [ 7, 20, 'Struct' ],
  BHHOUSE2 => [ 7, 20, 'Struct' ],
  BHHOUSE4 => [ 7, 20, 'Struct' ],
  BHIHOUS1 => [ 12, 20, 'Struct' ],
  BHJHOUS1 => [ 35, 30, 'Struct' ],
  BHJHOUS2 => [ 35, 30, 'Struct' ],
  BHMFARM1 => [ 19, 20, 'Struct' ],
  BHWTOWR1 => [ 9, 9, 'Struct' ],
  BHESHER1 => [ 50, 35, 'Struct' ],
  BHFTDAV1 => [ 100, 75, 'Struct' ],
  BHSCHOL1 => [ 55, 70, 'Struct' ],
  BHCHRCH1 => [ 35, 35, 'Struct' ],
  BHWTOWR2 => [ 9, 9, 'Struct' ],
  BHWTOWR3 => [ 9, 9, 'Struct' ],
  BHWTOWR4 => [ 9, 9, 'Struct' ],
  BHWTOWR5 => [ 9, 9, 'Struct' ],
  BHYCEME1 => [ 20, 5, 'Struct' ],
  BHYCEME2 => [ 5, 20, 'Struct' ],
  BHYCEME3 => [ 20, 20, 'Struct' ],
  BHYCEME4 => [ 5, 10, 'Struct' ],
  BHYCEME5 => [ 5, 10, 'Struct' ],
  BHYCEME6 => [ 5, 10, 'Struct' ],
  BCAIK1 => [ 65, 30, 'Struct' ],
  BCAIK2 => [ 65, 30, 'Struct' ],
  BCAIK3 => [ 65, 30, 'Struct' ],
  BCAIK4 => [ 65, 30, 'Struct' ],
  BCAIK5 => [ 65, 30, 'Struct' ],
  BCAIK6 => [ 65, 30, 'Struct' ],
  BCAIK7 => [ 65, 30, 'Struct' ],
  BCAIK8 => [ 65, 30, 'Struct' ],
  BCAIK_S1 => [ 25, 25, 'Struct' ],
  BCAIK_S2 => [ 25, 25, 'Struct' ],
  BCAIK_S3 => [ 25, 25, 'Struct' ],
  BCAIK_S4 => [ 25, 25, 'Struct' ],
  BCAIK_S5 => [ 25, 25, 'Struct' ],
  BCAIK_S6 => [ 25, 25, 'Struct' ],
  BCAIK_S7 => [ 25, 25, 'Struct' ],
  BCAIK_S8 => [ 25, 25, 'Struct' ],
  BCAIKGAT => [ 10, 5, 'Struct' ],
  BCAIKWAL => [ 300, 150, 'Struct' ],
  BCAIKWL1 => [ 30, 5, 'Struct' ],
  BCAIKWL2 => [ 30, 5, 'Struct' ],
  BCAIKWL3 => [ 40, 40, 'Struct' ],
  BCAIKWL4 => [ 30, 5, 'Struct' ],
  BCAIKWL5 => [ 10, 5, 'Struct' ],
  BCAIKWL6 => [ 5, 5, 'Struct' ],
  AARAMP1 => [ 20, 42, 'Ramp' ],
  AARAMP2 => [ 20, 36, 'Ramp' ],
  AARAMP3 => [ 20, 15, 'Ramp' ],
  AARAMP4 => [ 30, 25, 'Ramp' ],
  AARAMP5 => [ 10, 25, 'Ramp' ],
  AARAMP6 => [ 30, 25, 'Ramp' ],
  AARAMP7 => [ 15, 30, 'Ramp' ],
  AARAMPA => [ 15, 25, 'Ramp' ],
  AARAMPB => [ 15, 30, 'Ramp' ],

  A2FINSG1 => [ 10, 5, 'Decor', 15 ],
  BCZSTAG4 => [ 5, 5, 'Decor', 10 ],
  BCRHOPR1 => [ 10, 10, 'Decor', 15 ],
  AWATERT1 => [ 5, 5, 'Decor', 15 ],
  ASHACK1 => [ 5, 5, 'Decor', 10 ],
  AHUT1 => [ 5, 5, 'Decor', 10 ],
  ALEANTO1 => [ 5, 5, 'Decor', 10 ],

  BEOVRPS1 => [ 30, 125, 'Bridge' ],
  BEBRIDG1 => [ 10, 100, 'Bridge' ],
  BEBRIDG4 => [ 10, 160, 'Bridge' ],
  BEBRIDG3 => [ 10, 60, 'Bridge' ],
  BEBRIDG2 => [ 10, 80, 'Bridge' ],
  BEBRIDGA => [ 10, 80, 'Bridge' ],
  BEBRIDGB => [ 10, 60, 'Bridge' ],
  BEWDBRG1 => [ 10, 80, 'Bridge' ],
  BEWDBRG2 => [ 10, 60, 'Bridge' ],

  AMOILPM2 => [ 5, 15, 'Struct' ],

  ANBUNKR1 => [ 20, 25, 'Bunker' ],

  AOBILBD0 => [ 10, 5, 'Struct' ],
  AOBILBD1 => [ 10, 5, 'Struct' ],
  AOBILBD2 => [ 10, 5, 'Struct' ],
  AOBILBD3 => [ 10, 5, 'Struct' ],
  AOBILBD4 => [ 10, 5, 'Struct' ],
  AOBILBD5 => [ 10, 5, 'Struct' ],
  AOBILBD6 => [ 10, 5, 'Struct' ],
  AOBILBD7 => [ 10, 5, 'Struct' ],
  AOBILBD8 => [ 10, 5, 'Struct' ],
  AOBILBD9 => [ 10, 5, 'Struct' ],
  AOBILBDA => [ 10, 5, 'Struct' ],
  AOBILBDB => [ 10, 5, 'Struct' ],
  AOBILBDC => [ 10, 5, 'Struct' ],
  AOBILBDD => [ 10, 5, 'Struct' ],
  AOBILBDE => [ 10, 5, 'Struct' ],
  AFENCE4 => [ 5, 5, 'Struct' ],

  ARPROPN1 => [ 10, 5, 'Decor', 10],
  ATPOLE1 => [ 5, 5, 'Decor', 30 ],
  NSAGUAR1 => [ 5, 5, 'Decor', 10 ],
  AKWRECK1 => [ 5, 10, 'Decor', 5 ],
  AKWRECK2 => [ 5, 10, 'Decor', 5 ],
  BCZLITE1 => [ 2, 1, 'Decor', 15 ],
  BCZLITE2 => [ 1, 5, 'Decor', 15 ],

  SCROS_1 => [ 5, 5, 'SIGN' ],
  SDARM_1 => [ 5, 5, 'SIGN' ],
  SDBRD_1 => [ 5, 5, 'SIGN' ],
  SDCON_1 => [ 5, 5, 'SIGN' ],
  SDCRV_1 => [ 5, 5, 'SIGN' ],
  SDDED_1 => [ 5, 5, 'SIGN' ],
  SDRCL_1 => [ 5, 5, 'SIGN' ],
  SDROC_1 => [ 5, 5, 'SIGN' ],
  SDSCH_1 => [ 5, 5, 'SIGN' ],
  SDSLO_1 => [ 5, 5, 'SIGN' ],
  SDSTP_1 => [ 5, 5, 'SIGN' ],
  SDTIN_1 => [ 5, 5, 'SIGN' ],
  SDTIN_2 => [ 5, 5, 'SIGN' ],
  SDTIN_3 => [ 5, 5, 'SIGN' ],
  SDTRN_1 => [ 5, 5, 'SIGN' ],
  SDTRN_2 => [ 5, 5, 'SIGN' ],
  SDXIN_1 => [ 5, 5, 'SIGN' ],
  SDYIN_1 => [ 5, 5, 'SIGN' ],
  SEAIR_1 => [ 5, 5, 'SIGN' ],
  SEBAU_1 => [ 5, 5, 'SIGN' ],
  SECLR_1 => [ 5, 5, 'SIGN' ],
  SEDET_1 => [ 5, 5, 'SIGN' ],
  SEDON_1 => [ 5, 5, 'SIGN' ],
  SEEVR_1 => [ 5, 5, 'SIGN' ],
  SEFTD_1 => [ 5, 5, 'SIGN' ],
  SEG50_1 => [ 5, 5, 'SIGN' ],
  SEGRP_1 => [ 5, 5, 'SIGN' ],
  SEHOP_1 => [ 5, 5, 'SIGN' ],
  SEKER_1 => [ 5, 5, 'SIGN' ],
  SEMOR_1 => [ 5, 5, 'SIGN' ],
  SEOIL_1 => [ 5, 5, 'SIGN' ],
  SESEM_1 => [ 5, 5, 'SIGN' ],
  SESPN_1 => [ 5, 5, 'SIGN' ],
  SETWO_1 => [ 5, 5, 'SIGN' ],
  SEWGW_1 => [ 5, 5, 'SIGN' ],
  SL35X_1 => [ 5, 5, 'SIGN' ],
  SL50X_1 => [ 5, 5, 'SIGN' ],
  SL55X_1 => [ 5, 5, 'SIGN' ],
  SL55X_2 => [ 5, 5, 'SIGN' ],
  SLACF_1 => [ 5, 5, 'SIGN' ],
  SLZON_1 => [ 5, 5, 'SIGN' ],
  SMBRN_1 => [ 5, 5, 'SIGN' ],
  SMCAR_1 => [ 5, 5, 'SIGN' ],
  SMCTY_1 => [ 5, 5, 'SIGN' ],
  SMFIS_1 => [ 5, 5, 'SIGN' ],
  SMFTD_1 => [ 5, 5, 'SIGN' ],
  SMHOT_1 => [ 5, 5, 'SIGN' ],
  SMJ87_1 => [ 5, 5, 'SIGN' ],
  SMMAL_1 => [ 5, 5, 'SIGN' ],
  SMPLN_1 => [ 5, 5, 'SIGN' ],
  SMSEA_1 => [ 5, 5, 'SIGN' ],
  SMSET_1 => [ 5, 5, 'SIGN' ],
  SSTOP_1 => [ 5, 5, 'SIGN' ],
  SWAFB_1 => [ 5, 5, 'SIGN' ],
  SWBRN_1 => [ 5, 5, 'SIGN' ],
  SWCLR_1 => [ 5, 5, 'SIGN' ],
  SWDOG_1 => [ 5, 5, 'SIGN' ],
  SWEND_1 => [ 5, 5, 'SIGN' ],
  SWFED_1 => [ 5, 5, 'SIGN' ],
  SWFTL_1 => [ 5, 5, 'SIGN' ],
  SWMTR_1 => [ 5, 5, 'SIGN' ],
  SWPEC_1 => [ 5, 5, 'SIGN' ],
  SWPLA_1 => [ 5, 5, 'SIGN' ],
  SWQAR_1 => [ 5, 5, 'SIGN' ],
  SWROP_1 => [ 5, 5, 'SIGN' ],
  SWSEA_1 => [ 5, 5, 'SIGN' ],
  SWSEM_1 => [ 5, 5, 'SIGN' ],
  SWTAT_1 => [ 5, 5, 'SIGN' ],
  SWWHT_1 => [ 5, 5, 'SIGN' ],

  SH11N_1 => [ 5, 5, 'SIGN' ],
  SH11S_1 => [ 5, 5, 'SIGN' ],
  SH12E_1 => [ 5, 5, 'SIGN' ],
  SH12N_1 => [ 5, 5, 'SIGN' ],
  SH12S_1 => [ 5, 5, 'SIGN' ],
  SH12W_1 => [ 5, 5, 'SIGN' ],
  SH13N_1 => [ 5, 5, 'SIGN' ],
  SH13S_1 => [ 5, 5, 'SIGN' ],
  SH15N_1 => [ 5, 5, 'SIGN' ],
  SH15S_1 => [ 5, 5, 'SIGN' ],
  SH17E_1 => [ 5, 5, 'SIGN' ],
  SH17W_1 => [ 5, 5, 'SIGN' ],
  SH20N_1 => [ 5, 5, 'SIGN' ],
  SH20S_1 => [ 5, 5, 'SIGN' ],
  SH21N_1 => [ 5, 5, 'SIGN' ],
  SH21S_1 => [ 5, 5, 'SIGN' ],
  SH28N_1 => [ 5, 5, 'SIGN' ],
  SH28S_1 => [ 5, 5, 'SIGN' ],
  SH38E_1 => [ 5, 5, 'SIGN' ],
  SH38E_2 => [ 5, 5, 'SIGN' ],
  SH38N_1 => [ 5, 5, 'SIGN' ],
  SH38S_1 => [ 5, 5, 'SIGN' ],
  SH38W_1 => [ 5, 5, 'SIGN' ],
  SH38W_2 => [ 5, 5, 'SIGN' ],
  SH55E_1 => [ 5, 5, 'SIGN' ],
  SH55W_1 => [ 5, 5, 'SIGN' ],
  SH62E_1 => [ 5, 5, 'SIGN' ],
  SH62W_1 => [ 5, 5, 'SIGN' ],
  SH70E_1 => [ 5, 5, 'SIGN' ],
  SH70W_1 => [ 5, 5, 'SIGN' ],
  SH82E_1 => [ 5, 5, 'SIGN' ],
  SH82E_2 => [ 5, 5, 'SIGN' ],
  SH82W_1 => [ 5, 5, 'SIGN' ],
  SH82W_2 => [ 5, 5, 'SIGN' ],
  SH87N_1 => [ 5, 5, 'SIGN' ],
  SH87S_1 => [ 5, 5, 'SIGN' ],
  SJ13L_1 => [ 5, 5, 'SIGN' ],
  SJ13R_1 => [ 5, 5, 'SIGN' ],
  SJ20L_1 => [ 5, 5, 'SIGN' ],
  SJ20R_1 => [ 5, 5, 'SIGN' ],
  SJ21L_1 => [ 5, 5, 'SIGN' ],
  SJ21R_1 => [ 5, 5, 'SIGN' ],
  SJ38L_1 => [ 5, 5, 'SIGN' ],
  SJ38N_1 => [ 5, 5, 'SIGN' ],
  SJ38R_1 => [ 5, 5, 'SIGN' ],
  SJ38S_1 => [ 5, 5, 'SIGN' ],
  SJ62L_1 => [ 5, 5, 'SIGN' ],
  SJ62R_1 => [ 5, 5, 'SIGN' ],
  SJ87L_1 => [ 5, 5, 'SIGN' ],
  SJ87R_1 => [ 5, 5, 'SIGN' ],
  
  ICA21_1 => [ 20, 20, 'Intersection' ],
  ICA22_1 => [ 20, 20, 'Intersection' ],
  ICA23_1 => [ 20, 20, 'Intersection' ],
  IDISECT1 => [ 10, 20, 'Intersection' ],
  IDISECT2 => [ 10, 10, 'Intersection' ],
  IEISECT1 => [ 20, 20, 'Intersection' ],
  IGA21_1 => [ 24, 25, 'Intersection' ],
  IGA21_2 => [ 24, 25, 'Intersection' ],
  IGA22_1 => [ 24, 25, 'Intersection' ],
  IGA22_2 => [ 24, 25, 'Intersection' ],
  IGA23_1 => [ 24, 25, 'Intersection' ],
  IGA23_2 => [ 24, 25, 'Intersection' ],
  IGD27_1 => [ 24, 25, 'Intersection' ],
  IGW29_1 => [ 24, 25, 'Intersection' ],
  IJA2171 => [ 10, 20, 'Intersection' ],
  IJA2271 => [ 10, 20, 'Intersection' ],
  IJA2371 => [ 10, 20, 'Intersection' ],
  IJD27T1 => [ 10, 10, 'Intersection' ],
  IJD28T1 => [ 10, 10, 'Intersection' ],
  IJW29T1 => [ 10, 10, 'Intersection' ],
  ILA21_1 => [ 24, 25, 'Intersection' ],
  ILA21_2 => [ 24, 25, 'Intersection' ],
  ILA22_1 => [ 24, 25, 'Intersection' ],
  ILA22_2 => [ 24, 25, 'Intersection' ],
  ILA23_1 => [ 24, 25, 'Intersection' ],
  ILA23_2 => [ 24, 25, 'Intersection' ],
  ILD27_1 => [ 24, 25, 'Intersection' ],
  ILW29_1 => [ 24, 25, 'Intersection' ],
  IMA21_1 => [ 10, 10, 'Intersection' ],
  IMA21_2 => [ 10, 10, 'Intersection' ],
  IMA22_1 => [ 10, 10, 'Intersection' ],
  IMA22_2 => [ 10, 10, 'Intersection' ],
  IMA23_1 => [ 10, 10, 'Intersection' ],
  IMA23_2 => [ 10, 10, 'Intersection' ],
  ITA21_1 => [ 10, 10, 'Intersection' ],
  ITA22_1 => [ 10, 10, 'Intersection' ],
  ITA23_1 => [ 10, 10, 'Intersection' ],
  ITD27_1 => [ 10, 10, 'Intersection' ],
  ITISECT1 => [ 10, 10, 'Intersection' ],
  ITISECT2 => [ 10, 10, 'Intersection' ],
  IXA21_1 => [ 10, 10, 'Intersection' ],
  IXA22_1 => [ 10, 10, 'Intersection' ],
  IXA23_1 => [ 10, 10, 'Intersection' ],
  IXD27_1 => [ 10, 10, 'Intersection' ],
  IXISECT1 => [ 10, 10, 'Intersection' ],
  IXISECT2 => [ 10, 10, 'Intersection' ],
  IYD27_1 => [ 30, 45, 'Intersection' ],
  IYISECT1 => [ 24, 25, 'Intersection' ],
  IYISECT2 => [ 24, 25, 'Intersection' ],
  IYISECT3 => [ 24, 25, 'Intersection' ],
  IYISECT4 => [ 24, 25, 'Intersection' ],
  IYISECT5 => [ 24, 25, 'Intersection' ],
  IYISECT6 => [ 24, 25, 'Intersection' ],
  IYISECT8 => [ 30, 45, 'Intersection' ],
  RERWEND1 => [ 20, 25, 'Intersection' ],
  RERWEND2 => [ 20, 25, 'Intersection' ],
  RERWEND3 => [ 20, 25, 'Intersection' ],
  RERWEND4 => [ 20, 25, 'Intersection' ],
  RMRWMID1 => [ 20, 200, 'Intersection' ],

  A1FLAG1 => [ 0, 0, 'Flag', 'Red' ],
  A1FLAG2 => [ 0, 0, 'Flag', 'Green' ],
  A1FLAG3 => [ 0, 0, 'Flag', 'Med_Purple' ],
  A1FLAG4 => [ 0, 0, 'Flag', 'Black' ],
);

my @objects;

#################################################
# the I76 files are IFF format
#  however this script is a tremendous hack
#  most of the format is not respected and instead
#  a search for magic byte strings is used
while (! eof($fp)) {
  my $tag = _rd($_[0], 4);

  if ($tag eq 'ZONE') {
    # read zone (terrain file)
    $ptr += 9;
    seek $fp, $ptr, SEEK_SET;
    $zone = lc(unpack 'Z16', _rd($fp, 16));
    print "ZONE: $zone\n";
    $ptr += 16;
  } elsif ($tag eq 'ZMAP') {
    # read zone map (blocks)
    $ptr += 9;
    seek $fp, $ptr, SEEK_SET;
    for my $y (0 .. 79) {
      # ZMAP is stored upside-down
      $zmap[$y] = [ unpack('C80', _rd($fp, 80)) ];
    }
    $ptr += 6400;
  } elsif (unpack('N', $tag) == 0x4F424A00) {
    # object - parse
    my ($temp_name, @f) = unpack('x4a8f23', _rd($fp, 104));
    my $obj_name = uc( unpack('Z8', join('', map { chr(ord($_) & 0x7F) } split //, $temp_name)) );
    print "OBJ: $obj_name ($f[9], $f[11])\n";

    if (exists $obj{$obj_name}) {
      my $oW = $obj{$obj_name}[0];
      my $oH = $obj{$obj_name}[1];
      if ($obj{$obj_name}[2] eq 'Struct') {
        push @objects, "box { <0, 0, 0> <$oW, 15, $oH>\n texture { T_Stone32 }\n matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      } elsif ($obj{$obj_name}[2] eq 'Bridge') {
        push @objects, "box { <0, 0, 0> <$oW, 5, $oH>\n texture { T_Wood20 }\n matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      } elsif ($obj{$obj_name}[2] eq 'Ramp') {
        my $rH = ($oW < $oH ? $oW : $oH) / 2;
        push @objects, "prism { linear_sweep linear_spline -$oW 0 4 <0, 0> <0, $oH> <$rH, $oH> <0, 0> texture { T_Stone21 } rotate <0, 0, 90> matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      } elsif ($obj{$obj_name}[2] eq 'Bunker') {
        push @objects, "union { prism { conic_sweep linear_spline 0.75 1 5 <-$oW/2, -$oH/2>,<$oW/2, -$oH/2>,<$oW/2, $oH/2>, <-$oW/2, $oH/2>, <-$oW/2, -$oH/2> rotate<180, 0, 0> translate<$oW/2, 1, $oH/2> scale<1, 60, 1>\n texture { T_Stone18 }\n } cone { <" . ($oW / 2) . ', 30, ' . ($oH / 2) . ">, " . ($oW / 3) . " <" . ($oW / 2) . ', 20, ' . ($oH / 2) . ">, 0 texture { T_Gold_3A } } matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      } elsif ($obj{$obj_name}[2] eq 'Decor') {
        my $rH = ($oW < $oH ? $oW : $oH) / 2;
        push @objects, "cylinder { <0.5, 0, 0.5>, <0.5, " . $obj{$obj_name}[3] . ", 0.5>, 0.5\n scale <" . $obj{$obj_name}[0] . ", 1, " . $obj{$obj_name}[1] . ">\n texture { T_Wood7 }\n matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      } elsif ($obj{$obj_name}[2] eq 'Flag') {
        push @objects, "union { union { box { <0, 0, 0> <5, 2.5, 5> }\n cylinder { <2.5, 2.5, 2.5> <2.5, 40, 2.5>, 2.5 }\n box { <1.25, 32.5, 2.5> <3.75, 40, 12.5> }\n texture { pigment { " . $obj{$obj_name}[3] . " }\n  finish { ambient 0.5\ndiffuse 0.4\nspecular 0.1\n} } } sphere { <2.5, 42.5, 2.5> 10/3 texture { T_Gold_3A } } matrix <" . join(',', @f[0 .. 11]) . ">\n}\n";
      }
    } elsif ($obj_name !~ m/^CHECK\d+$/) {
      die " . UNKNOWN object!!\n";
    }
    $ptr += 108;
  } elsif (! $name && unpack('V', $tag) == 0x00000258) {
    # magic string that typically indicates Map Name
    $ptr += 4;
    seek $fp, $ptr, SEEK_SET;
    $name = unpack 'Z32', _rd($fp, 32);
    print "NAME: $name\n";
    $ptr += 32;
  } else {
    # advance 1 byte
    $ptr ++;
  }

  # bail if we read everything
  #last if (@zmap && $zone && $name);

  seek $fp, $ptr, SEEK_SET;
}
close $fp;

# crop ZMAP
my ($wMin, $wMax, $hMin, $hMax) = (0, 79, 0, 79);
my $doCrop = 1;
do {
  for my $x (0 .. 79)
  {
    if ($zmap[$hMin][$x] < 255) { $doCrop = 0 }
  }
  if ($doCrop) { $hMin ++ }
} while ($doCrop);
$doCrop = 1;
do {
  for my $x (0 .. 79)
  {
    if ($zmap[$hMax][$x] < 255) { $doCrop = 0 }
  }
  if ($doCrop) { $hMax -- }
} while ($doCrop);
$doCrop = 1;
do {
  for my $y ($hMin .. $hMax)
  {
    if ($zmap[$y][$wMin] < 255) { $doCrop = 0 }
  }
  if ($doCrop) { $wMin ++ }
} while ($doCrop);
$doCrop = 1;
do {
  for my $y ($hMin .. $hMax)
  {
    if ($zmap[$y][$wMax] < 255) { $doCrop = 0 }
  }
  if ($doCrop) { $wMax -- }
} while ($doCrop);

print "Cropped w=0,79 to w=$wMin, $wMax.\nCropped h=0,79 to h=$hMin, $hMax.\n";

# workaround for case-sensitive filesystems
my %terfiles;
opendir(my $dh, '.');
while (readdir $dh) {
  if ($_ =~ m/.*\.ter$/i) {
    $terfiles{lc($_)} = $_;
  }
}
closedir $dh;

# great now open the .ter file
my @blocks;
my $i = 0;
open my $ter, '<:raw', $terfiles{$zone};
while (!eof($ter)) {
  print "Parsing block $i\n";

  for my $y (0 .. 127) {
    for my $x (0 .. 127) {
      $blocks[$i][$y][$x] = unpack 'v', _rd($ter, 2);
    }
  }

  $i ++;
}
close $ter;

my $imgW = $wMax - $wMin + 1;
my $imgH = $hMax - $hMin + 1;

# build one huge output file
#  everything is done backwards so, it must be flipped for write
my $sum = 0;
my $peak = 0;
{
  my @rows;
  for my $h ($hMin .. $hMax) {
    for my $y (0 .. 127) {
      my $row;
      for my $w ($wMin .. $wMax) {
        my $z = $zmap[$h][$w];
        #if ($y == 127) { if ($z == 255) { print " " } else { print "X" } }
        if ($z == 255) {
          $row .= ("\0" x 256);
        } else {
          for my $x (0 .. 127) {
	    $sum += ($blocks[$z][$y][$x] & 0x0FFF) / 4096;
            $row .= pack('n', 1 + ($blocks[$z][$y][$x] & 0x0FFF));
            if (($blocks[$z][$y][$x] & 0x0FFF) > $peak) { $peak = ($blocks[$z][$y][$x] & 0x0FFF) }
          }
        }
      }
      unshift @rows, $row;
    }
    #print "\n";
  }
  
  open my $pgm, '>:raw', '/tmp/out.pgm';
  print $pgm "P5\n" . (2 + (128 * $imgW)) . ' ' . (2 + (128 * $imgH)) . "\n4095\n";
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  print $pgm "\0\0" . $_ . "\0\0" for @rows;
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  close $pgm;
  `pnmtopng /tmp/out.pgm > /tmp/$ARGV[0].heightmap.png`;
}

my $avg_height = $sum / ($imgW * 128 * $imgH * 128);
print STDERR "average map height is $avg_height\n";

# tarmac road mask
my $hasRoads = 0;
{
  my @rows;
  for my $h ($hMin .. $hMax) {
    for my $y (0 .. 127) {
      my $row;
      for my $w ($wMin .. $wMax) {
        my $z = $zmap[$h][$w];
        #if ($y == 127) { if ($z == 255) { print " " } else { print "X" } }
        if ($z == 255) {
          $row .= ("\0" x 256);
        } else {
          for my $x (0 .. 127) {
            if (($blocks[$z][$y][$x] & 0x6000) == 0x4000) { $hasRoads = 1; $row .= pack('n', 1 + ($blocks[$z][$y][$x] & 0x0FFF)) } else { $row .= "\0\0" }
          }
        }
      }
      unshift @rows, $row;
    }
    #print "\n";
  }
  open my $pgm, '>:raw', '/tmp/out.pgm';
  print $pgm "P5\n" . (2 + (128 * $imgW)) . ' ' . (2 + (128 * $imgH)) . "\n4095\n";
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  print $pgm "\0\0" . $_ . "\0\0" for @rows;
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  close $pgm;
  `pnmtopng /tmp/out.pgm > /tmp/$ARGV[0].roadmask.png`;
}

# dirt road mask
my $hasDirt = 0;
{
  my @rows;
  for my $h ($hMin .. $hMax) {
    for my $y (0 .. 127) {
      my $row;
      for my $w ($wMin .. $wMax) {
        my $z = $zmap[$h][$w];
        #if ($y == 127) { if ($z == 255) { print " " } else { print "X" } }
        if ($z == 255) {
          $row .= ("\0" x 256);
        } else {
          for my $x (0 .. 127) {
            if (($blocks[$z][$y][$x] & 0x6000) == 0x6000) { $hasDirt = 1; $row .= pack('n', 1 + ($blocks[$z][$y][$x] & 0x0FFF)) } else { $row .= "\0\0" }
          }
        }
      }
      unshift @rows, $row;
    }
    #print "\n";
  }
  open my $pgm, '>:raw', '/tmp/out.pgm';
  print $pgm "P5\n" . (2 + (128 * $imgW)) . ' ' . (2 + (128 * $imgH)) . "\n4095\n";
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  print $pgm "\0\0" . $_ . "\0\0" for @rows;
  print $pgm ("\0\0" x (2 + (128 * $imgW)));
  close $pgm;
  `pnmtopng /tmp/out.pgm > /tmp/$ARGV[0].dirtmask.png`;
}

# create the POV file
open my $pov, '>', $ARGV[0] . '.pov';

my $max = ($imgW < $imgH ? $imgH : $imgW);
# position the camera
print $pov "#version 3.6;\n#include \"screen.inc\"\n#include \"colors.inc\"\n#include \"stones.inc\"\n#include \"golds.inc\"\n#include \"woods.inc\"\n\nSet_Camera(<-$max - $avg_height, $max + ($avg_height / 2), -$max - $avg_height>, <0, $avg_height / 2, 0>, 30)\nSet_Camera_Aspect(16,9)\n\n";

# light, infinite green ground
print $pov "light_source {\n  <0, 2, 0> color rgb<1, 1, 1>\n  area_light x*($max + 1), z*($max + 1), 3 * $max, 3 * $max adaptive 1 circular\n  // fade_distance 2 fade_power 1\n}\n";

print $pov "background { color White }\n";

print $pov "plane { <0,1,0>, 0\npigment{ color Green } finish { ambient 0.3\ndiffuse 0.6\nspecular 0.1\n}}\n";

# the three terrain objects (ground, dirt, tarmac)
print $pov "union {\n";
print $pov "height_field {\n  png\n  \"/tmp/$ARGV[0].heightmap.png\"\n  smooth\n  water_level 1/65535\n  translate <0, -1/65535, 0>\n pigment { gradient y\n    color_map {\n    [0 color Green]\n    [$peak / 8191 color Yellow]\n[$peak / 4095 color Red]\n} }\n finish { ambient 0.3\ndiffuse 0.6\nspecular 0.1\n}\n}\n";
if ($hasRoads) {
 print $pov "height_field {\n  png\n  \"/tmp/$ARGV[0].roadmask.png\"\n  smooth\n  water_level 1/65535\n texture { T_Stone41 \n  }\n}\n";
}
if ($hasDirt) {
 print $pov "height_field {\n  png\n  \"/tmp/$ARGV[0].dirtmask.png\"\n  smooth\n  water_level 1/65535\n texture { T_Stone44 \n  }\n}\n";
}

# centers the height fields about origin
print $pov "  translate <-.5, 0, -.5>\n scale<$imgW + 1/64, 0.64, $imgH + 1/64>\n  rotate<0, clock * 360, 0>\n }\n";

# place any objects we want to show
if (@objects) {
  print $pov "union {\n";
  foreach (@objects) {
    print $pov $_;
  }
  print $pov "  scale <1/640, 1/640, 1/640>\n";
  print $pov "  translate < -$wMin - ($imgW / 2), 0, -$hMin - ($imgH / 2) >\n";
  print $pov "  rotate<0, clock * 360, 0>\n";
  print $pov "}\n";
}

# print the Map Name in bottom-right corner
print $pov "#declare MyTextObject = text {\nttf \"crystal.ttf\", \"$name\", 0.01, <0,0>\nscale 0.08\n pigment {color White}\n finish {ambient 1 diffuse 0}\n }\n\n";
print $pov "Screen_Object ( MyTextObject, <1,0>, <0.04,0.02>, true, 0.01 )\n";

close $pov;

# some sample commands to render frames and produce an output video
#`povray37 -W1920 -H1080 +A +Q11 +KFF600 +KC -D $ARGV[0].pov`;
#`ffmpeg -r 60 -i $ARGV[0]%03d.png -crf 0 $ARGV[0].mp4`;

#`povray36 -W1280 -H720 +A +KFF240 +KC $ARGV[0].pov`;
#`ffmpeg -r 24 -i $ARGV[0]%03d.png -pix_fmt yuv420p -crf 0 $ARGV[0].mp4`;

#`rm $ARGV[0]*.png`;
