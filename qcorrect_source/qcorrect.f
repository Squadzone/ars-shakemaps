      module traceinfo
      implicit none
      save
           integer            :: nsamp, npoint
           integer            :: year, month, day, doy
           integer            :: hour, minute, second, milsec
           real               :: sr, stdist, trace(1050000)
           real               :: stalat, stalon, stah
           character (len=12) :: event, stime
           character          :: staname*4, comp*3
      end module

      module timeseries
      implicit none
      save
           real, dimension (1050000)    :: deglitched,detrended,windowed
           real, dimension (1050000)    :: padded,four_amp
           real, dimension (1050000)    :: disp,vel,acc
           real                         :: trend_a, trend_b
      end module

      module spectra
      implicit none
      save
           real, dimension (1050000)    :: freq, fa, fp, smoothfa
           complex, dimension (1050000) :: disp_spec, vel_spec,acc_spec
           complex, dimension (1050000) :: fouriered, filtered
      end module

      module respinfo
      implicit none
      save
           integer            :: nzero, npole
           real               :: A0ok
           complex            :: z(100), p(100)
           double precision   :: A0, f0, sensitivity
      end module

      module par
      implicit none
      save
           integer            :: iglit, itrend, ifilt, iresp
           integer            :: norder, nfreq, ismooth
           real               :: taper, flcut, fhcut
           real               :: freq1, freq2, damp, fbox
           character (len=30) :: elist
      end module

      module datapar
      implicit none
      save
           integer            :: nchannel
           character (len=30) :: SEEDfile, dirname, channels(10000)
           character (len=500):: root, eve_path, chan_path
      end module

      module eqpar
      implicit none
      save
           integer            :: eqdate(6)
           real               :: eqmsecond
           real               :: eqcoord(3), eqmag, eqdist
      end module

      module eventlistpar
      implicit none
      save
           integer            :: ieflag, n_eventlist
           integer            :: filedate(6)
           character (len=200):: eventlist(100000)
      end module

      program icorrect
      use respinfo 
      use par
      use datapar
      use traceinfo
      use timeseries
      use spectra
      use eqpar
      use eventlistpar

      implicit none
      integer                    :: i
      character (len=50)         :: dat_file, resp_file, tmppath
      write(*,*)'Reading parameter file: par.dat'
      call readpar()
      write(*,*)'Reading the SEED file:'
      call getinput()
      write(*,*)'Creating and naming event directory:'
      call make_evedir()
      Write(*,*)'Runing RDSEED and decompressing data:' 
      call chdir(trim(eve_path))
c      open (unit=39,file=trim(dirname)//'.txt',status='new')
c      open (unit=39,file=dirname(5:len_trim(dirname))//'.txt',
c     1      status='new')
      call system('rdseed -R -d -o 6 -f '//trim(dirname)//'.SEED')
      Write(*,*)'Checking for segmented files and merging if any:'
      call merge_all()
c      write(*,*)'Creating channel directories and copying data in them:'
      write(*,*)'Working on channels paths:'
      call make_channeldirs()
      open(unit=57,file='summary.txt',status='new')
      do i=1,nchannel
          write(*,10)'Processing channel # ',i,' out of ',nchannel,' :'
10        format(a21,i3,a8,i3,a2)
c          call chdir(trim(eve_path)//'/'//trim(channels(i)))
          call find_dat_resp(channels(i),dat_file,resp_file)
          if(len(trim(dat_file))==0.or.len(trim(resp_file))==0)cycle
c          call find_dat_resp(dat_file,resp_file)
          if(i==1)write(57,*)'Sta.   Comp.   Lat.     Lon.     Dist.'
     1        //'     0.10      0.20'
     2        //'     0.33      0.50      1.00      2.00      3.00'
     3        //'      5.00     10.00      20.00     PGA       PGV'
          call process_channel(dat_file,resp_file)
c          call write_for_matlab()
      enddo 
      call system('rm -f *SAC_ASC RESP* resp* sac*')
      close(unit=57)
c      close(unit=39)
c      call chdir(trim(root))
      end
