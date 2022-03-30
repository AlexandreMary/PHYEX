#!/bin/bash
#SBATCH -n 2
#SBATCH --mem=20000
#SBATCH -t 00:10:00
#SBATCH -N 1
#SBATCH -p normal256

#The MYLIB varibale must contain the gmkpack pack name
#Results will be stored in the local directory

#Other environment varaibles that can be set:
#OUTPUTDIR

date

OUTPUTDIR=${OUTPUTDIR:-$PWD}
case=riette2
#rekchemin=/home/khatib
#rekchemin=/home/riette/AROME/export
if [ $(hostname | cut -c 1-7) == 'belenos' ]; then
  rekchemin=/scratch/work/riette/202005_externalisation_physique/conf_tests/small_3D
else
  rekchemin=/cnrm/phynh/data1/riette/DATA/202005_externalisation_physique/conf_tests/small_3D
fi

NPROC=2
NSTRIN=$NPROC
NSTROUT=1
NPRTRW_NPRTRV=""
NPRTRW_NPRTRV="  NPRTRW=$NPROC,
  NPRTRV=1,"
export OMP_NUM_THREADS=1

#MYLIB=48t1_main.01%jpdup

export DR_HOOK=1
#export DR_HOOK_IGNORE_SIGNALS=-1
export DR_HOOK_NOT_MPI=1
export DR_HOOK_SILENT=1
export DR_HOOK_OPT=

export EC_PROFILE_HEAP=0
export EC_PROFILE_MEM=0
export EC_MPI_ATEXIT=0
export DR_HOOK_SHOW_PROCESS_OPTIONS=0
export EC_MEMINFO=0
export TVSEARCHPATH=$SOURCE

HOMEPACK=${HOMEPACK:=$HOME/pack}
SOURCE=$HOMEPACK/$MYLIB/src/local
LOADIR=$HOMEPACK/$MYLIB/bin

TMPDIR=${TMPDIR:=$HOME/tmp}
TMPLOC=$TMPDIR/rundir.$$
TMPWAIT=$TMPDIR/wait_queue.$$
mkdir $TMPWAIT
mkdir $TMPLOC
cd $TMPLOC

export RTTOV_COEFDIR=$PWD

#      **************************
#      *  Saisie des NAMELISTS  *
#      **************************

CNMEXP='FPOS'

echo
/bin/cat <<FIN > fort.4
 &NACIETEO
 /
 &NACOBS
 /
 &NACTAN
 /
 &NACTEX
 /
 &NACVEG
 /
 &NADOCK
 /
 &NAEAEM7
 /
 &NAEAER
 /
 &NAECOAPHY
 /
 &NAEPHLI
 /
 &NAEPHY
 /
 &NAERAD
   LRRTM=.TRUE.,
   LSRTM=.FALSE.,
   NAER=1,
   NICEOPT=3,
   NLIQOPT=3,
   NOVLP=6,
   NOZOCL=2,
   NRADFR=18,
   NRADIP=3,
   NRADLP=2,
   NSW=6,
   RLWINHF=1,
   RRE2DE=0.64952,
   RSWINHF=1,
 /
 &NAERCLI
 /
 &NAEVOL
 /
 &NAIMPO
 /
 &NALORI
 /
 &NAMAFN
   GFP_CLSG%CLNAME='SURFACCGRAUPEL',
   GFP_CLSP%CLNAME='SURFACCPLUIE',
   GFP_CLSS%CLNAME='SURFACCNEIGE',
   GFP_SFIS%IBITS=16,
   GFP_ST%CLNAME='SURFTEMPERATURE',
   GFP_ST%IANO=0,
   GFP_ST%IBITS=12,
   GFP_X10U%CLNAME='CLSVENT.ZONAL',
   GFP_X10U%IANO=0,
   GFP_X10U%IBITS=12,
   GFP_X10V%CLNAME='CLSVENT.MERIDIEN',
   GFP_X10V%IANO=0,
   GFP_X10V%IBITS=12,
   GFP_X2RH%CLNAME='CLSHUMI.RELATIVE',
   GFP_X2RH%IANO=0,
   GFP_X2RH%IBITS=12,
   GFP_X2T%CLNAME='CLSTEMPERATURE',
   GFP_X2T%IANO=1,
   GFP_XCCC%IBITS=8,
   GFP_XHCC%IBITS=8,
   GFP_XLCC%IBITS=8,
   GFP_XLSG%CLNAME='SURFINSGRAUPEL',
   GFP_XLSP%CLNAME='SURFINSPLUIE',
   GFP_XLSS%CLNAME='SURFINSNEIGE',
   GFP_XMCC%IBITS=8,
   GFP_XN2T%IBITS=12,
   GFP_XTCC%IBITS=8,
   GFP_XUGST%CLNAME='CLSU.RAF60M.XFU',
   GFP_XUGST%IANO=0,
   GFP_XUGST%IBITS=12,
   GFP_XVGST%CLNAME='CLSV.RAF60M.XFU',
   GFP_XVGST%IANO=0,
   GFP_XVGST%IBITS=12,
   GFP_XX2T%IBITS=12,
   GFP_XXDIAGH%IBITS=12,
   TFP_ABS%ZFK=32.,
   TFP_CLF%IBITS=6,
   TFP_EDR%CLNAME='EDR',
   TFP_EDR%IBITS=16,
   TFP_EDR%IGRIB=136,
   TFP_GR%IBITS=12,
   TFP_HL%IBITS=12,
   TFP_HTB%IBITS=16,
   TFP_HTB%LLGP=.TRUE.,
   TFP_HU%IBITS=12,
   TFP_MSAT9C2%IBITS=12,
   TFP_MSAT9C6%IBITS=12,
   TFP_MSLNH%IBITS=12,
   TFP_PV%ZFK=64.,
   TFP_RCLS%IBITS=12,
   TFP_RR%IBITS=12,
   TFP_SN%IBITS=12,
   TFP_T%IBITS=12,
   TFP_TCLS%IBITS=12,
   TFP_TH%IBITS=12,
   TFP_THPW%IBITS=12,
   TFP_THV%IBITS=12,
   TFP_TN%IBITS=12,
   TFP_TWV%IBITS=12,
   TFP_TX%IBITS=12,
   TFP_U%IBITS=12,
   TFP_V%IBITS=12,
   TFP_VOR%ZFK=32.,
   TFP_VV%ZFK=32.,
 /
 &NAMARG
   CNMEXP='${CNMEXP}',
   LECMWF=.FALSE.,
   LELAM=.TRUE.,
   LSLAG=.TRUE.,
   NCONF=1,
   NSUPERSEDE=1,
 /
 &NAMARPHY
   LKFBCONV=.FALSE.,
   LKFBD=.FALSE.,
   LKFBS=.FALSE.,
   LMFSHAL=.TRUE.,
   LMICRO=.TRUE.,
   LMPA=.TRUE.,
   LMSE=.TRUE.,
   LTURB=.TRUE.,
 /
 &NAMCA
 /
 &NAMCAPE
 /
 &NAMCFU
   LCUMFU=.TRUE.,
   LFPLS=.TRUE.,
   LFPLSG=.TRUE.,
   LFR=.TRUE.,
   LFRRC=.TRUE.,
   LFSF=.TRUE.,
   LNEBPAR=.TRUE.,
   LNEBTT=.TRUE.,
   LRAYD=.TRUE.,
   LRAYS=.TRUE.,
 /
 &NAMCHEM
 /
 &NAMCHET
 /
 &NAMCHK
 /
 &NAMCLA
 /
 &NAMCLDP
 /
 &NAMCLI
 /
 &NAMCLOP15
 /
 &NAMCLTC
 /
 &NAMCOK
 /
 &NAMCOM
 /
 &NAMCOSJO
 /
 &NAMCOUPLO4
 /
 &NAMCT0
   CFPNCF='ECHFP',
   CNPPATH=' ',
   LAROME=.TRUE.,
   LNHEE=.TRUE.,
   LSCREEN_OPENMP=.FALSE.,
   LSPRT=.TRUE.,
   LTWOTL=.TRUE.,
   NFPOS=1,
   NFRSDI=18,
   NSDITS(0)=0,
   NFRHIS=72,
   NHISTS(0)=0,
   NFRPOS=72,
   NPOSTS(0)=0,
   NFRSFXHIS=72,
   NSFXHISTS(0)=0,
   NFRDHFD=72,
   NDHFDTS(0)=0,
 /
 &NAMCT1
   LRFILAF=.FALSE.,
   N1HIS=1,
   N1POS=1,
   N1RES=0,
   N1SDI=1,
   N1SFXHIS=1,
   N1GDI=0,
 /
 &NAMCUMF
 /
 &NAMCUMFS
 /
 &NAMCVER
 /
 &NAMCVMNH
 /
 &NAMDDH
   LDDH_OMP=.TRUE.,
   LHDDOP=.TRUE.,
   LHDHKS=.TRUE.,
   LHDEFD=.TRUE.,
   LFLEXDIA=.TRUE.,
   BDEDDH(1,1)=3,
   BDEDDH(2,1)=1,
   BDEDDH(3,1)=358.8
   BDEDDH(4,1)=45.1
   BDEDDH(5,1)=360.3
   BDEDDH(6,1)=44.5
 /
 &NAMDFI
 /
 &NAMDIM
   NPROMA=-50,
 /
 &NAMDIMO
 /
 &NAMDIM_TRAJ
 /
 &NAMDPHY
 /
 &NAMDPRECIPS
 /
 &NAMDYN
   LADVF=.TRUE.,
   LQMPD=.FALSE.,
   LQMT=.FALSE.,
   LQMVD=.FALSE.,
   LRHDI_LASTITERPC=.TRUE.,
   NITMP=4,
   NSITER=1,
   NSPDLAG=3,
   NSVDLAG=3,
   NTLAG=3,
   NVLAG=3,
   NWLAG=3,
   RDAMPDIV=20.,
   RDAMPPD=20.,
   RDAMPQ=0.,
   RDAMPT=0.,
   RDAMPVD=20.,
   RDAMPVOR=20.,
   REPS1=0.,
   REPS2=0.,
   REPSM1=0.,
   REPSM2=0.,
   REPSP1=0.,
   SDRED=1.,
   SIPR=90000.,
   SITR=350.,
   SITRA=100.,
   SLHDA0=0.25,
   SLHDD00=0.000065,
   VESL=0.05,
   XIDT=0.,
   ZSLHDP1=1.7,
   ZSLHDP3=0.6,
 /
 &NAMDYNA
   LCOMADH=.TRUE.,
   LCOMADV=.FALSE.,
   LCOMAD_GFL=.TRUE.,
   LCOMAD_SP=.TRUE.,
   LCOMAD_SPD=.TRUE.,
   LCOMAD_SVD=.TRUE.,
   LCOMAD_T=.TRUE.,
   LCOMAD_W=.TRUE.,
   LGWADV=.TRUE.,
   LNESC=.TRUE.,
   LPC_CHEAP=.TRUE.,
   LPC_FULL=.TRUE.,
   LRDBBC=.FALSE.,
   LSETTLS=.FALSE.,
   LSETTLST=.TRUE.,
   LSLHD_GFL=.TRUE.,
   LSLHD_OLD=.FALSE.,
   LSLHD_SPD=.FALSE.,
   LSLHD_SVD=.FALSE.,
   LSLHD_T=.FALSE.,
   LSLHD_W=.FALSE.,
   ND4SYS=2,
   NDLNPR=1,
   NPDVAR=2,
   NVDVAR=4,
   SLHDEPSH=0.08,
   SLHDKMAX=6,
 /
 &NAMDYNCORE
 /
 &NAMEMIS_CONF
 /
 &NAMENKF
 /
 &NAMFA
   CMODEL='OUTPUTID',
   LEXTERN=.TRUE.,
   LSUPPDATE=.FALSE.,
   NBITCS=-1,
   NBITPG=-1,
   NSTRON=-1,
 /
 &NAMFAINIT
   JPXTRO=2000,
 /
 &NAMFPC
   CFP2DF(1)='SURFPRESSION',
   CFP2DF(2)='MSL_NHPRESSURE',
   CFP2DF(3)='SURFTOT.WAT.VAPO',
   CFP2DF(4)='SURFISOTPW0.MALT',
   CFP2DF(5)='SURFCAPE.POS.F00',
   CFP2DF(6)='C002_METEOSAT_09_SEVIRI.POS',
   CFP2DF(7)='C006_METEOSAT_09_SEVIRI.POS',
   CFP2DF(8)='SURFREFLECT.MAX',
   CFP2DF(9)='SURFISOTPW1.MALT',
   CFP2DF(10)='SURFISOTPW2.MALT',
   CFP3DF(1)='GEOPOTENTIEL',
   CFP3DF(2)='TEMPERATURE',
   CFP3DF(3)='VENT_ZONAL',
   CFP3DF(4)='VENT_MERIDIEN',
   CFP3DF(5)='HUMI_RELATIVE',
   CFP3DF(6)='THETA_PRIM_W',
   CFP3DF(7)='PRESSURE',
   CFP3DF(8)='ABS_VORTICITY',
   CFP3DF(9)='VITESSE_VERTICALE',
   CFP3DF(10)='TEMPE_POTENT',
   CFP3DF(11)='POT_VORTICIT',
   CFP3DF(12)='SIM_REFLECTI',
   CFP3DF(13)='RAIN',
   CFP3DF(14)='SNOW',
   CFP3DF(15)='GRAUPEL',
   CFP3DF(16)='ICE_CRYSTAL',
   CFP3DF(17)='CLOUD_WATER',
   CFP3DF(18)='VERT.VELOCIT',
   CFP3DF(19)='DIVERGENCE',
   CFP3DF(20)='THETA_VIRTUA',
   CFP3DF(21)='TKE',
   CFP3DF(22)='CLOUD_FRACTI',
   CFP3DF(23)='ISOT_ALTIT',
   CFP3DF(24)='EDR',
   CFPCFU(1)='SURFTENS.TOTA.ZO',
   CFPCFU(2)='SURFTENS.TOTA.ME',
   CFPCFU(3)='SURFACCPLUIE',
   CFPCFU(4)='SURFACCNEIGE',
   CFPCFU(5)='SURFACCGRAUPEL',
   CFPCFU(6)='SOMMFLU.RAY.SOLA',
   CFPCFU(7)='SURFFLU.RAY.SOLA',
   CFPCFU(8)='SOMMFLU.RAY.THER',
   CFPCFU(9)='SURFFLU.RAY.THER',
   CFPCFU(10)='SURFFLU.LAT.MTOT',
   CFPCFU(11)='SURFFLU.MTOTA.NE',
   CFPCFU(12)='SURFFLU.CHA.SENS',
   CFPCFU(13)='SURFRAYT SOLA DE',
   CFPCFU(14)='SURFRAYT THER DE',
   CFPCFU(15)='SURFRAYT SOL CL',
   CFPCFU(16)='SURFRAYT THER CL',
   CFPCFU(17)='SURFRAYT DIR SUR',
   CFPDOM(1)='FRANGP0025',
   CFPFMT='LALON',
   CFPPHY(1)='SURFTEMPERATURE',
   CFPPHY(2)='INTSURFGEOPOTENT',
   CFPPHY(3)='SURFRESERV.NEIGE',
   CFPXFU(1)='CLSTEMPERATURE',
   CFPXFU(2)='CLSHUMI.RELATIVE',
   CFPXFU(3)='CLSVENT.ZONAL',
   CFPXFU(4)='CLSVENT.MERIDIEN',
   CFPXFU(5)='SURFNEBUL.TOTALE',
   CFPXFU(6)='SURFNEBUL.HAUTE',
   CFPXFU(7)='SURFNEBUL.MOYENN',
   CFPXFU(8)='SURFNEBUL.BASSE',
   CFPXFU(9)='CLSMAXI.TEMPERAT',
   CFPXFU(10)='CLSMINI.TEMPERAT',
   CFPXFU(11)='CLPMHAUT.MOD.XFU',
   CFPXFU(12)='SURFDIAGHAIL',
   LCRITSNOWTEMP=.FALSE.,
   LFPCAPEX=.TRUE.,
   LFPMOIS=.TRUE.,
   LFPPACKING=.FALSE.,
   LWIDER_DOM=.TRUE.,
   L_READ_MODEL_DATE=.TRUE.,
   NFITI=1,
   NFITV=1,
   NFPCAPE=5,
   NFPCLI=1,
   NFPGRIB=1,
   NFPINPHY=4,
   NITERPV=8,
   RENTRA=0.0001,
   RFP3H(1)=10.,
   RFP3H(2)=20.,
   RFP3H(3)=35.,
   RFP3H(4)=50.,
   RFP3H(5)=75.,
   RFP3H(6)=100.,
   RFP3H(7)=150.,
   RFP3H(8)=200.,
   RFP3H(9)=250.,
   RFP3H(10)=375.,
   RFP3H(11)=500.,
   RFP3H(12)=625.,
   RFP3H(13)=750.,
   RFP3H(14)=875.,
   RFP3H(15)=1000.,
   RFP3H(16)=1125.,
   RFP3H(17)=1250.,
   RFP3H(18)=1375.,
   RFP3H(19)=1500.,
   RFP3H(20)=1750.,
   RFP3H(21)=2000.,
   RFP3H(22)=2250.,
   RFP3H(23)=2500.,
   RFP3H(24)=2750.,
   RFP3H(25)=3000.,
   RFP3I(1)=-273.15,
   RFP3I(2)=-263.15,
   RFP3I(3)=-261.15,
   RFP3I(4)=-253.15,
   RFP3P(1)=10000.,
   RFP3P(2)=12500.,
   RFP3P(3)=15000.,
   RFP3P(4)=17500.,
   RFP3P(5)=20000.,
   RFP3P(6)=22500.,
   RFP3P(7)=25000.,
   RFP3P(8)=27500.,
   RFP3P(9)=30000.,
   RFP3P(10)=35000.,
   RFP3P(11)=40000.,
   RFP3P(12)=45000.,
   RFP3P(13)=50000.,
   RFP3P(14)=55000.,
   RFP3P(15)=60000.,
   RFP3P(16)=65000.,
   RFP3P(17)=70000.,
   RFP3P(18)=75000.,
   RFP3P(19)=80000.,
   RFP3P(20)=85000.,
   RFP3P(21)=90000.,
   RFP3P(22)=92500.,
   RFP3P(23)=95000.,
   RFP3P(24)=100000.,
   RFP3PV(1)=0.0000015,
   RFP3PV(2)=0.000002,
   RFPCD2=5.,
   RFPCSAB=50.,
   RFPVCAP=7000.,
 /
 &NAMFPD
   NLAT(1)=41,
   NLON(1)=41,
   RLONC(1)=-0.71,
   RLATC(1)=44.8,
   RDELX(1)=0.025,
   RDELY(1)=0.025,
 /
 &NAMFPDY2
 /
 &NAMFPDYF
 /
 &NAMFPDYH
 /
 &NAMFPDYI
 /
 &NAMFPDYP
 /
 &NAMFPDYS
 /
 &NAMFPDYT
 /
 &NAMFPDYV
 /
 &NAMFPF
   NFMAX(1)=60,
   NFMAX(2)=80,
 /
 &NAMFPG
   NFPDISTRIB=1,
 /
 &NAMFPIOS
 /
 &NAMFPMOVE
 /
 &NAMFPPHY
 /
 &NAMFPSC2
   NFPROMA=-50,
 /
 &NAMFPSC2_DEP
   NFPROMA_DEP=-50,
 /
 &NAMGEM
 /
 &NAMGFL
   NGFL_EZDIAG=4,
   YEZDIAG_NL(1)%CNAME='EZDIAG01',
   YEZDIAG_NL(1)%LREQOUT=.FALSE.,
   YEZDIAG_NL(2)%CNAME='EZDIAG02',
   YEZDIAG_NL(2)%LREQOUT=.FALSE.,
   YEZDIAG_NL(3)%CNAME='EZDIAG03',
   YEZDIAG_NL(3)%LREQOUT=.FALSE.,
   YEZDIAG_NL(4)%CNAME='INPRRTOT3D',
   YEZDIAG_NL(4)%LREQOUT=.TRUE.,
   YG_NL%LQM=.TRUE.,
   YG_NL%LSLHD=.TRUE.,
   YG_NL%NCOUPLING=-1,
   YG_NL%NREQIN=1,
   YG_NL%REFVALC=0.,
   YIRAD_NL%LGP=.TRUE.,
   YI_NL%LQM=.TRUE.,
   YI_NL%LSLHD=.TRUE.,
   YI_NL%NCOUPLING=-1,
   YI_NL%NREQIN=1,
   YI_NL%REFVALC=0.,
   YLRAD_NL%LGP=.TRUE.,
   YL_NL%LQM=.TRUE.,
   YL_NL%LSLHD=.TRUE.,
   YL_NL%NCOUPLING=-1,
   YL_NL%NREQIN=1,
   YL_NL%REFVALC=0.,
   YQ_NL%LCOMAD=.TRUE.,
   YQ_NL%LQM=.TRUE.,
   YQ_NL%LSLHD=.FALSE.,
   YQ_NL%NREQIN=1,
   YR_NL%LQM=.TRUE.,
   YR_NL%LSLHD=.TRUE.,
   YR_NL%NCOUPLING=-1,
   YR_NL%NREQIN=1,
   YR_NL%REFVALC=0.,
   YS_NL%LQM=.TRUE.,
   YS_NL%LSLHD=.TRUE.,
   YS_NL%NCOUPLING=-1,
   YS_NL%NREQIN=1,
   YS_NL%REFVALC=0.,
   YTKE_NL%NCOUPLING=0,
   YTKE_NL%NREQIN=1,
 /
 &NAMGRIB
 /
 &NAMGWD
 /
 &NAMGWDIAG
 /
 &NAMGWWMS
 /
 &NAMIAU
   ALPHAIAU=0.5,
   LIAU=.FALSE.,
   TSTARTIAU=1800,
   TSTOPIAU=5340,
 /
 &NAMICE
 /
 &NAMINI
   LDFI=.FALSE.,
 /
 &NAMINTFLEX
 /
 &NAMIOMI
 /
 &NAMIOS
 /
 &NAMIO_SERV
   NIO_SERV_BUF_MAXSIZE=20,
   NIO_SERV_METHOD=2,
   NMSG_LEVEL_CLIENT=0,
   NMSG_LEVEL_SERVER=0,
   NPROCESS_LEVEL=5,
   NPROC_IO=0,
 /
 &NAMJBCODES
 /
 &NAMJFH
 /
 &NAMJG
 /
 &NAMLCZ
 /
 &NAMLSFORC
 /
 &NAMMARS
 /
 &NAMMCC
 /
 &NAMMCUF
 /
 &NAMMKODB
 /
 &NAMMODERR
 /
 &NAMMTS
 /
 &NAMMWAVE
 /
 &NAMNPROF
 /
 &NAMNUD
 /
 &NAMOBS
 /
 &NAMONEDVAR
 /
 &NAMOOPS
 /
 &NAMOPH
   CFNHWF='ECHIS',
   LINC=.TRUE.,
   NTIMEFMT=1,
 /
 &NAMOPTCMEM
 /
 &NAMPAR0
   LOPT_SCALAR=.TRUE.,
   NPRINTLEV=1,
   LMPOFF=.FALSE.,
   MBX_SIZE=2048000000,
   MP_TYPE=2,
   NOUTPUT=1,
   NPROC=$NPROC,
$NPRTRW_NPRTRV
 /
 &NAMPAR1
   LEQ_REGIONS=.FALSE.,
   LSLONDEM=.TRUE.,
   LSPLIT=.TRUE.,
   LSYNC_SLCOM=.FALSE.,
   LSYNC_TRANS=.FALSE.,
   L_GATHERV_WRGP=.FALSE.,
   NCOMBFLEN=1800000,
   NSTRIN=$NSTRIN,
   NSTROUT=$NSTROUT,
 /
 &NAMPARAR
   CFRAC_ICE_ADJUST='S',
   CFRAC_ICE_SHALLOW_MF='S',
   CMICRO='ICE3',
   CSEDIM='STAT',
   CSNOWRIMING='M90',
   LCONVHG=.TRUE.,
   LCRFLIMIT=.TRUE.,
   LCRIAUTI=.TRUE.,
   LEVLIMIT=.TRUE.,
   LFEEDBACKT=.TRUE.,
   LFPREC3D=.TRUE.,
   LNULLWETG=.TRUE.,
   LNULLWETH=.TRUE.,
   LOLSMC=.TRUE.,
   LOSEDIC=.TRUE.,
   LOSIGMAS=.TRUE.,
   LOSUBG_COND=.TRUE.,
   LSEDIM_AFTER=.FALSE.,
   LWETGPOST=.TRUE.,
   LWETHPOST=.TRUE.,
   NMAXITER_MICRO=1,
   NPRINTFR=10000,
   NPTP=1,
   RCRIAUTC=0.001,
   RCRIAUTI=0.0002,
   RT0CRIAUTI=-5.,
   VSIGQSAT=0.02,
   XFRACM90=0.1,
   XMRSTEP=0.00005,
   XSPLIT_MAXCFL=0.8,
   XTSTEP_TS=0.,
 /
 &NAMPHMSE
   LPGDFWR=.FALSE.,
 /
 &NAMPHY
   LAERODES=.TRUE.,
   LAEROLAN=.TRUE.,
   LAEROSEA=.TRUE.,
   LAEROSOO=.TRUE.,
   LEDR=.TRUE.,
   LMPHYS=.TRUE.,
   LO3ABC=.TRUE.,
   LRAYFM=.TRUE.,
 /
 &NAMPHY0
   ALMAV=300.,
   BEDIFV=0.05,
   ECMNP=3000.,
   GCCSV=0.,
   GCVADS=0.8,
   GCVALFA=0.000045,
   GCVBETA=0.2,
   GCVMLT=0.00016,
   GCVNU=0.000025,
   GCVPSI=1.,
   GCVPSIE=1.,
   GDDEVA=0.25,
   GDDSDE=0.5,
   GWDCD=6.,
   HUCOE=0.5,
   HUTIL=1.8,
   QSSC=400.,
   QSSUSC=0.75,
   QSSUSS=0.4,
   QSSUSV=250.,
   QSUSXC=0.0002,
   QSUSXS=0.0003,
   QXRAL=130.,
   QXRDEL=0.49,
   QXRHX=0.99,
   QXRR=0.25,
   RCVEVAP=0.25,
   REFLKUO=5000.,
   REVGSL=15.,
   SCO=-20.,
   TDDGP=0.8,
   TENTR=0.0000025,
   TENTRX=0.00008,
   TUDGP=0.8,
   UHDIFV=0.0008,
   USURIC=0.175,
   USURICE=0.5,
   USURICL=1.,
   USURID=0.1,
   USURIDE=0.25,
   VZ0CM=0.00015,
   XMAXLM=5000.,
   XMINLM=10.,
 /
 &NAMPHY1
   ALBMIN=0.65,
   ALCRIN=0.75,
   GCGEL=0.00003,
   GCGELS=0.00005,
   GNEIMX=1.8,
   GNEIMXS=1.8,
   RCTVEG(3)=0.000012,
   RCTVEG(4)=0.00001,
 /
 &NAMPHY2
   FACRAF=3.8,
   HTKERAF=20.,
   LMULAF=.TRUE.,
   LRAFTKE=.TRUE.,
   LRAFTUR=.TRUE.,
   XDAMP=1.,
   XMULAF=-1.85,
 /
 &NAMPHY3
 /
 &NAMPHYDS
 /
 &NAMPONG
 /
 &NAMPPC
 /
 &NAMPPVI
 /
 &NAMPRE
 /
 &NAMRAD15
 /
 &NAMRADCMEM
 /
 &NAMRCF
 /
 &NAMRCOEF
 /
 &NAMRES
 /
 &NAMRGRI
 /
 &NAMRINC
 /
 &NAMRIP
    TSTEP=50.,
    CSTOP='h2',
 /
 &NAMRIP0
 /
 &NAMRLX
 /
 &NAMSATS
   LPARTIAL_COEF_FILES=.TRUE.,
 /
 &NAMSCC
 /
 &NAMSCEN
 /
 &NAMSCM
 /
 &NAMSEKF
 /
 &NAMSENS
 /
 &NAMSFXCMP
   CFLDNAME(1)='????????????????',
   NBBITS(1)=24,
 /
 &NAMSIMPHL
 /
 &NAMSPNG
 /
 &NAMSPSDT
 /
 &NAMSTA
 /
 &NAMSTOPH
 /
 &NAMSWE
 /
 &NAMTESTVAR
 /
 &NAMTHLIM
 /
 &NAMTOPH
   ETCVIM=5000.,
   ETNEBU=5000.,
   ETPLUI=5000.,
   XDRMTK=6.0D-7,
   XDRMTP=800.,
   XDRMUK=3.0D-7,
   XDRMUP=800.,
 /
 &NAMTRAJP
 /
 &NAMTRANS
 /
 &NAMTRANS0
 /
 &NAMTS
 /
 &NAMVAR
 /
 &NAMVARBC
 /
 &NAMVARBC_AIREP
 /
 &NAMVARBC_ALLSKY
 /
 &NAMVARBC_GBRAD
 /
 &NAMVARBC_RAD
 /
 &NAMVARBC_SFCOBS
 /
 &NAMVARBC_TCWV
 /
 &NAMVARBC_TO3
 /
 &NAMVAREPS
 /
 &NAMVDF
 /
 &NAMVDOZ
 /
 &NAMVOLCANO
 /
 &NAMVRTL
 /
 &NAMVV0
 /
 &NAMVV1
 /
 &NAMVWRK
 /
 &NAMWAVELETJB
 /
 &NAMXFU
   LXCLP=.TRUE.,
   LXCLS=.TRUE.,
   LXFU=.TRUE.,
   LXNEBPA=.TRUE.,
   LXNEBTT=.TRUE.,
   LXNUVCLS=.TRUE.,
   LXPLS=.TRUE.,
   LXPLSG=.TRUE.,
   LXQCLS=.TRUE.,
   LXR=.TRUE.,
   LXSOIL=.FALSE.,
   LXTHW=.TRUE.,
   LXTRT=.TRUE.,
   LXTTCLS=.TRUE.,
   LXXDIAGH=.TRUE.,
   LXXGST=.TRUE.,
   NFRRAZ=72,
   NRAZTS(0)=0,
 /
 &NAM_CANAPE
 /
 &NAM_DISTRIBUTED_VECTORS
 /
 &NAPHLC
 /
 &NEMCT0
 /
 &NEMDIM
 /
 &NEMDYN
 /
 &NEMELBC0A
   LESPCPL=.TRUE.,
   NBICNHX=2,
   NBICOP=2,
   NBICOT=2,
   NBICOU=2,
   NBICPD=2,
   NBICVD=2,
   NECRIPL=1,
 /
 &NEMELBC0B
   NEFRSPCPL=1,
   NEK0=20,
   NEK1=30,
   NEN1=4,
   NEN2=8,
   SPNUDDIV=0.01,
   SPNUDQ=0.,
   SPNUDT=0.01,
   SPNUDVOR=0.01,
   TEFRCL=3600.,
 /
 &NEMFPEZO
 /
 &NEMGEO
 /
 &NEMJK
 /
 &NEMVAR
 /
 &NEMWAVELET
 /
 &NAETLDIAG
 /
 &NAMMETHOX
 /
 &NAMSPP
 /
 &NAMACV
 /
 &NAMFPOBJ
 /
 &NAMNORGWD
 /
 &NAMTRAJ
 /
 &NAMSATSIM
 /
 &NAMDVISI
 /
 &NAMNUDGLH
 /
 &NAMPERTPAR
 /
FIN
/bin/cat fort.4

/bin/cat <<FIN > EXSEG1.nam
 &NAM_DIAG_ISBAN
   LPGD=.TRUE.,
   LSURF_MISC_BUDGET=.TRUE.,
 /
 &NAM_DIAG_SURFN
   LCOEF=.TRUE.,
   LSURF_BUDGET=.TRUE.,
   N2M=2,
 /
 &NAM_ISBAN
   CSCOND='NP89',
 /
 &NAM_REPROD_OPER
   LREPROD_OPER=.TRUE.,
 /
 &NAM_SEAFLUXN
   CSEA_FLUX='ECUME',
   LPWG=.FALSE.,
   LPRECIP=.FALSE.,
   LPWEBB=.FALSE.,
 /
 &NAM_SSON
   CROUGH='Z01D',
   XFRACZ0=5.,
   LDSV=.FALSE.,
 /
 &NAM_SURF_ATM
   XRIMAX=0.2,
   LNOSOF=.TRUE.,
 /
 &NAM_SURF_CSTS
   XZ0SN=0.01,
   XZ0HSN=0.001,
   XEMISSN=0.99,
 /
 &NAM_WRITE_DIAG_SURFN
   LPROVAR_TO_DIAG=.FALSE.,
   LSELECT=.TRUE.,
CSELECT(1)='T2M','HU2M','XX','YY','DX','DY','SST','Z0SEA','TS_WATER','Z0WATER','TG1','TG2','TG3','WG1','WG2','WG3','WGI1','WGI2','WGI3','WR','WSN_VEG1','RSN_VEG1','ASN_VEG','TSRAD_NAT','RESA','TROOF1','TROOF2','TROOF3','TROOF4','TROOF5','WS_ROOF','TROAD1','TROAD2','TROAD3','TROAD4','TROAD5','WS_ROAD','TWALL1','TWALL2','TWALL3','TWALL4','TWALL5','TI_BLD','T_WIN1','TI_ROAD','WSN_RF1','RSN_RF1','TSN_RF1','ASN_RF','WSN_RD1','RSN_RD1','TSN_RD1','ASN_RD','TCANYON','QCANYON','STORAGE_TYPE','MASDEV','VERSION','BUG','DIM_FULL','DTCUR','LAT0','LON0','RPK','BETA','LATORI','LONORI','IMAX','JMAX','RW_PRECIP','BUDC','SEA_OCEAN','SEA_SBL','WAT_SBL','SN_VEG_N','SN_VEG','LSNOW_FRAC_T','GLACIER','TEMPARP','NLITTER','NLITTLEVS','NSOILCARB','ISBA_CANOPY','SN_RF_N','SN_RF','SN_RD_N','SN_RD','SN_RD_TYP','SN_RF_TYP','TEB_CANOPY','STORAGETYPE','CARTESIAN','GRID_TYPE','SN_VEG_TYP','RESPSL','ROAD_DIR','WALL_OPT','LAI','VEG','RSMIN','DG2','_FBUF_SIZE','_FBUF_DIM1','_FBUF_DIM2','_FBUF_NAME','_FBUF_TYPE','_FBUF_MASK','LCPL_GCM','HANDLE_SIC','SSS',
 /
 &NAM_WRITE_SURF_ATM
   LNOWRITE_TEXFILE=.TRUE.,
 /
FIN
/bin/cat EXSEG1.nam

#      *****************************************
#      *  Acquisition du fichier de demarrage  *
#      *****************************************

echo
for hh in 0 1 2 3 4 5 6 ; do
  N=`expr $hh / 1 `
  set -x
  ln -s $rekchemin/data/aro/$case/ELSCFFCSTALBC000${N}_l15 ELSCF${CNMEXP}ALBC00${N}
  set +x
done
set -x
ln -s $rekchemin/data/aro/$case/ICMSHFCSTINIT_l15 ICMSH${CNMEXP}INIT
ln -s $rekchemin/data/aro/$case/ICMSHFCSTINIT.sfx ICMSH${CNMEXP}INIT.sfx
ln -s $rekchemin/data/surfex/v8/ecoclimapI_covers_param.bin .
ln -s $rekchemin/data/surfex/v8/ecoclimapII_eu_covers_param.bin .
ln -s $rekchemin/data/surfex/v8/ecoclimapII_af_covers_param.bin .
ln -s $rekchemin/data/aro/$case/Const.Clim Const.Clim
ln -s $rekchemin/data/aro/$case/Const.Clim.sfx Const.Clim.sfx
ln -s $rekchemin/data/aro/$case/const.clim.FRANGP0025 const.clim.FRANGP0025
ln -s $rekchemin/data/rttov12/rtcoef_meteosat_9_seviri.dat .
ln -s $rekchemin/data/rttov12/rtcoef_meteosat_10_seviri.dat .
ln -s $rekchemin/data/rttov12/sccldcoef_meteosat_9_seviri.dat .
set +x
tar xfz $rekchemin/data/rtm/radiation_params.47r1_light.tgz

#      ***************
#      *  Chargement *
#      ***************

echo
set -x
\ln -s $LOADIR/MASTERODB MASTER
set +x
if ldd MASTER | grep openmpi > /dev/null; then
  #On est sur PC
  MPILIB=$(ldd MASTER | grep openmpi | tail -1 | awk '{print $3}' | awk -F "/" '{print $(NF-2)}')
  MPIRUN="$(echo $(dirname $(dirname $(ldd MASTER | grep openmpi| tail -1 | awk '{print $3}'))))/bin/orterun --oversubscribe -np $NPROC"
  GRIB_API=$(dirname $(dirname $(ldd MASTER | grep grib_api | head -1 | awk '{print $3}') 2>/dev/null) 2>/dev/null)
  ECCODES=$(dirname $(dirname $(ldd MASTER | grep eccodes | head -1 | awk '{print $3}') 2>/dev/null) 2>/dev/null)
  export GRIB_SAMPLES_PATH=$GRIB_API/share/grib_api/ifs_samples/grib1
  export GRIB_DEFINITION_PATH=$GRIB_API/share/grib_api/definitions
  export ECCODES_SAMPLES_PATH=$ECCODES/share/eccodes/ifs_samples/grib1
  export ECCODES_DEFINITION_PATH=$rekchemin/data/eccodes_extras_definitions:$ECCODES/share/eccodes/definitions
else
  #On est sur HPC
  #MPIRUN="$(echo $(dirname $(dirname $(ldd MASTER | grep libmpi| tail -1 | awk '{print $3}'))))/bin/mpirun -wdir $PWD"
  NNODES=$SLURM_JOB_NUM_NODES
  MPITASKS_PER_NODE=$((SLURM_NTASKS/SLURM_JOB_NUM_NODES))
  MPI_TASKS=$SLURM_NTASKS
  MPIRUN="/opt/softs/mpiauto/mpiauto -np $MPI_TASKS -nnp $MPITASKS_PER_NODE --"
  export OMP_STACKSIZE=4G
  export KMP_STACKSIZE=4G
  export KMP_MONITOR_STACKSIZE=4G
  export DR_HOOK=1
  export DR_HOOK_IGNORE_SIGNALS=-1
  export DR_HOOK_SILENT=1
  export DR_HOOK_SHOW_PROCESS_OPTIONS=0
  export MPL_MBX_SIZE=2048000000
  export EC_PROFILE_HEAP=0
  export EC_PROFILE_MEM=0
  export EC_MPI_ATEXIT=0
  export EC_MEMINFO=0
  export OPENBLAS_NUM_THREADS=1
  export MKL_CBWR="AUTO,STRICT"
  export MKL_NUM_THREADS=1
  export MKL_DEBUG_CPU_TYPE=5
  export ECCODES_SAMPLES_PATH=/opt/softs/libraries/ICC_2018.5.274/eccodes-2.17.0/share/eccodes/ifs_samples/grib1
  export ECCODES_DEFINITION_PATH=/opt/softs/libraries/ICC_2018.5.274/eccodes-2.17.0/share/eccodes/definitions
fi
echo $MPIRUN
set +x
if [ ! -f MASTER ] ; then echo No executable MASTER;exit 1;fi

#      ***************
#      *  Execution  *
#      ***************

echo
echo OMP_NUM_THREADS=$OMP_NUM_THREADS
set -x
ulimit -s unlimited
$MPIRUN $PWD/MASTER >lola
set +x
echo
##if [ -f lola ] ; then
##  echo;echo Standard output :;echo;cat lola
##fi
##if [ -f stderr.* ] ; then
##  for file in stderr.* ; do
##    echo;echo $file :;cat $file
##  done
##fi
##if [ -f stdout.* ] ; then
##echo;echo stdout :;echo;cat stdout.*
##fi
##if [ -a NODE.001_01 ] ; then
##  for file in NODE* ; do
##    echo;echo Listing $file;echo
##    cat $file
##  done
##fi
##if [ $(find . -name "drhook.prof.*" | wc -l) -ne 0 ] ; then
### Top 25 for each MPI task :
##  for file in drhook.prof.* ; do
##    echo;echo $file :;head -38 $file
##  done
##fi
#cat drhook.prof.* | perl -w $HOME/bin/drhook_merge_walltime_max.pl

#      *******************
#      *  Sauvegardes    *
#      *******************

ls
#if [ -f PFFPOS000+0000 ] ; then
#  cp PFFPOS000+0000 $WAIT_QUEUE/PFFPOS000+0000.$PBS_JOBID
#fi
cp lola NODE.001_01 ICMSHFPOS+00* DHFDLFPOS+00* $OUTPUTDIR/
/bin/rm fort.4 EXSEG1.nam lola ICMSHFPOS+0000* PFFPOSFRANGP0025+0000* ICMSHFPOS+0001*
/bin/rm PFFPOSFRANGP0025+0001* ICMSHFPOS+0002* ECHIS PFFPOSFRANGP0025+0002* DHFDLFPOS+00*
/bin/rm ECHFP NODE.001_01 ifs.stat $(tar tfz $rekchemin/data/rtm/radiation_params.47r1_light.tgz)

#      ****************
#      *  Epilogue    *
#      ****************

ls -ltr | grep -v "\->"
echo Wait_queue :
ls -ltr $TMPWAIT
cd $TMPDIR
\rm -rf rundir.$$
\rm -rf wait_queue.$$
date
set +x
