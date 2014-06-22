! Control file for program tmrs_loop_td_drvr
! This program is also a substitute for tmr_loop_rv_drvr.
! Revision of program involving a change in the control file on this date:
   07/21/13
!Name of Summary File:
  ENA.sum
!
!Comment:
! (This is written to the summary file,
! but not the output column file containing
! the results)
  Generalized Equivalent Single-Corner Point-Source Simulations for ENA
!Name of file with SMSIM input parameters:
! ***WARNING*** If want the stress parameter to be used,
! be sure that the source specified
! in the parameter file uses DeltaSigma as a parameter
! (of the 12 sources currently built into the smsim
! programs, only sources 1, 2, 11, and 12 use the DeltaSigma
! as a free parameter).
  ENA_Z.params
!Name of Output Column File for response spectra (and pga. pgv) output:
  ENA_Z.col
!Character Tag to Add to Column Labels (up to 4 characters):
  ENA1
! Damp
 0.05
!log-spaced periods (0) or individual periods (1)
 1
!if log-spaced periods: nper, per_start, per_stop:
!if individual periods: nper, list of nper periods:
! Note that pgv and pga are computed automatically, so per = - 1 or 0
! should not be specified.  If want only pgv and pga, specify nper <= 0
! 200 0.01 100.0
 9
 5
 3.03
 2
 1
 0.5
 0.3003
 0.2016
 0.1
 0.05
!m_start, delta_m, m_stop (linear spaced):
 2.5 0.1 7
!log-spaced distances (0) or individual distances (1)
 0
!if log-spaced distances: nr, r_start, r_stop:
!if individual distances: nr, list of nr distances:
! 200 1.0 400.0
 39 0.1 630.9573445
!Parameters M1, h1, c0, c1, c2, c3, M2, h2 for pseudodepth used to convert loop R values (assumed to be
!  Rjb unless the pseudodepth = 0.0, as would be given by specifying h1=h2=c0=c1=c2=c3=0.0; or 
!  by specifying M1=20.0 (or some other number greater than largest magnitude for which the motions are
!  to be computed) and h1=0.0), in which case it is assumed that the loop R values are Rrup).
!  The equation is
!     M <= M1: h = h1
!     M1< M < M2: h = c0+c1*M+c2*M^2+c3*M^3
!     M >= M2: h = h2
!   Note that all the parameters are read in one read statement, so that they can be strung together on
!   one line if desired.  I have separated them into three lines for clarity.
! 3.75  0.0
! 0.0 0.0 0.0 0.0
! 7.50  0.0 
! The values below are from work done in C:\nga_w2\rrup_rjb_conversion
 2.5  0.0
 0.0 0.0 0.0 0.0
 6.0  0.0
!stress from params file (-1), log-spaced stresses (0) or individual stress (1)
 1
!if log-spaced stresses: nstress, stress_start, stress_stop:
!if individual stresses: nstress, list of nstress stresss:
!NOTE: if choose stress from params file, then the input below is not used
!  This allows using an M-dependent stress option, as specified by the parameters
!  stressc, dlsdm, and amagc in the params field, for sources for which stress is a free
!  parameter (such as sources 1, 2, 11, and 12).
 19 1 50 100 150 200 250 300 350 400 450 500 550 600 700 800 900 1000 1200 1500
 
