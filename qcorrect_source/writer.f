      subroutine writer()
      use traceinfo
      use timeseries
      use spectra
      use respinfo
      use par
      use eqpar
      implicit none
      integer                     :: i
c      open(unit=3,file='result.txt',status='unknown')
      open(unit=3,file=trim(staname)//'.'//trim(comp)//'.tra',
     1     status='unknown')
      write(3,'(a18)')'EVENT INFORMATION:' 
      write(3,11)eqdate(1:3)
11    format('Event date:            ',i4.4,'/',i2.2,'/',i2.2)
      write(3,12)eqdate(4:6),eqmsecond
12    format('Event origon time:       ',i2.2,':',i2.2,':',i2.2,f4.3)
      write(3,13)eqcoord(1)
13    format('Epicenter latitude:    ',f9.4)
      write(3,14)eqcoord(2)
14    format('Epicenter longitude:   ',f9.4)
      write(3,15)eqcoord(3)
15    format('Hypocentral depth(km): ',f7.2)
      write(3,16)eqmag
16    format('Magnitude:             ',f7.2)
      write(3,17)staname, stdist
17    format('Distance from ',a4,' :   ',f8.2,1x,'km')
      write(3,'(a19)')'RECORD INFORMATION:'
      write(3,20)year, month, day, stime   
20    format('Beginning of record:   ',i4,2('/',i2.2),' ',a12)
      write(3,21)sr
21    format('Sampling rate:         ',f9.4)
      write(3,22)nsamp,npoint
22    format('# of samples:          ',i6,/,
     1       '# after padding:       ',i6)
      write(3,'(a20)')'STATION INFORMATION:'
      write(3,23)staname,comp
23    format('Station name:          ',a4,/,
     1       'Component:             ',a3)
      write(3,231)stalat,stalon,stah
231   format('Station latitude:      ',f9.4,/,
     1       'Station longitude:     ',f9.4,/,
     2       'Station height:        ',f7.2)
c      if(iglit.eq.0)then
c           write(3,24)
c24         format('GLITCHES:',/,'Glitches removed:     No')
c      else
c           write(3,25)
c25         format('GLITCHES:',/,'Glitches removed:     Yes')
c      endif
c      if(itrend.eq.0)then
c           write(3,26)
c26         format('TREND AND OFFSET:',/,'Trend/offset removed: No')
c      else
c           write(3,27)
c27         format('TREND AND OFFSET:',/,'Trend/offset removed: Yes')
c           write(3,'(a)')'A and B values in equation: y=Ax+B'
c           write(3,28)trend_a,trend_b
c28         format('A and B values:       ',2(g13.5,2x))
c      endif
c      write(3,29)taper
c29    format('TAPERING:',/,'Tapering window type: Cosine',/,'Tapering wi
c     1ndow ratio: ',f6.5)
c      if(ifilt.eq.0)then
c           write(3,30)
c30         format('FILTER:',/,'Filter applied:       No')
c      else
c           write(3,31)
c31         format('FILTER:',/,'Filter applied:       Yes')
c           write(3,32)
c32         format('Filter type:          Butterworth')
c           write(3,33)norder
c33         format('Filter order:         ',i2)
c           write(3,34)flcut, fhcut
c34         format('Frequency range:      ',f7.3,' to ',f7.3,' Hertz')
c      endif
c      write(3,'(a32)')'INSTRUMENT RESPONSE INFORMATION:'
c      if(iresp == 0)then
c           write(3,'(a)')'Instrument correction: Not applied'
c      else
c           write(3,'(a)')'Instrument correction: Applied'
c           write(3,35)A0
c35         format('Normalization factor: ',g13.5)
c           write(3,36)f0
c36         format('Normalization freq.:  ',g13.5)
c           write(3,37)nzero
c37         format('Number of zeros:      ',i2,' in:')
c           do i=1,nzero
c                write(3,'(2(2x,g13.5))')real(z(i)),imag(z(i))
c           enddo
c           write(3,38)npole
c38         format('Number of poles:      ',i2,' in:')
c           do i=1,npole
c                write(3,'(2(2x,g13.5))')real(p(i)),imag(p(i))
c           enddo
c           write(3,39)sensitivity
c39         format('Overall sensitivity:  ',g13.5)
c           if(A0ok.eq.1)then
c                write(3,'(a)')'Normalization factor: Matches'
c           else
c                write(3,'(a)')'Normalization factor: Does not match'
c           endif
c      endif
c      write(3,40)
c40    format('Calibration files in SAC, SEED, GSE2, and PITSA formats cr
c     1eated in channel folder')
c      write(3,'(a30)')'RESPONSE SPECTRUM INFORMATION:'
c      write(3,'(a)')'PSA information file: PSA.out'
c      if(ismooth.eq.0)then
c           write(3,'(a)')'Response spectrum:    Not smoothed'
c      else
c           write(3,'(a)')'Response spectrum:    Smoothed'
c           write(3,41)fbox
c41         format('Smoothing box width:  ',f8.5,'Hz in each side')
c      endif
      Write(3,'(a)')'END_HEADER'
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write(3,61)
c61    format('   Sample #   |   Original   |  Deglitched  |  Detrended   
c     1 |   Windowed   |<--   Fourier transform   -->| Fourier(Amp) |   F
c     2iltered   | Instr. corr. Disp., Vel., Acc. Amp. Spect. | Instr. co
c     3rr. Disp., Vel., Acc. time history|',/,'                  (Count) 
c     4       (Count)        (Count)        (Count)        Re(Count*s)   
c     5Im(Count*s)     (Count*s)      (Count*s)      (Meter*s)       (Met
c     6er)       (Meter/s)       (Meter)       (Meter/s)      (CM/s^2)')
61    format('    Time      |   Velocity   | Acceleration |',/,
     1       '    Sec.          (Meter/s)      (CM/s^2)') 
      do i=1,npoint,1
c           write(3,'(3(g13.6,2x))')i, trace(i), deglitched(i),
c     1     detrended(i), windowed(i), fouriered(i), four_amp(i),
c     2     cabs(filtered(i)), cabs(disp_spec(i)), cabs(vel_spec(i)),
c     3     cabs(acc_spec(i)), disp(i), vel(i), acc(i)
           write(3,'(3(e13.6,2x))')real(i-1)/sr, vel(i), acc(i)
      enddo
      close(unit=3)
      return
c     comment
      end
