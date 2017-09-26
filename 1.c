#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include "msm_mdp.h"

int main()
{
  int fbfd = 0;
  struct fb_var_screeninfo vinfo;
  struct fb_fix_screeninfo finfo;
  long int screensize = 0;
  char volatile *fbp = 0;
  int x = 0, y = 0;
  long int location = 0;
  int count ;
  struct  mdp_display_commit commit;
  memset( &commit, 0, sizeof commit );

  /* Open the file for reading and writing */
  fbfd = open("/dev/graphics/fb0", O_RDWR);
  if (!fbfd) {
    printf("Error: cannot open framebuffer device.\n");
    exit(1);
  }
  printf("The framebuffer device was opened successfully.\n");
  /* Get fixed screen information */
  if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo)) {
    printf("Error reading fixed information.\n");
    exit(2);
  }

  /* Get variable screen information */
  if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo)) {
    printf("Error reading variable information.\n");
    exit(3);
  }
  vinfo.activate = FB_ACTIVATE_FORCE;
//  vinfo.yoffset = 0;
  commit.flags |=  MDP_DISPLAY_COMMIT_OVERLAY;
  commit.var = vinfo;
  if (ioctl(fbfd, MSMFB_DISPLAY_COMMIT, &commit)) {
    printf("Error writing commit information.\n");
    exit(3);
  }
  if (ioctl(fbfd, FBIOPUT_VSCREENINFO, &vinfo)) {
    printf("Error writing variable information.\n");
    exit(3);
  }

  /* Figure out the size of the screen in bytes */
  screensize = vinfo.xres_virtual * vinfo.yres_virtual * vinfo.bits_per_pixel / 8;
  printf("\nScreen size is %d",screensize);
  printf("\nVinfo.bpp = %d",vinfo.bits_per_pixel);

  /* Map the device to memory */
  fbp = (char *)mmap(0, finfo.smem_len, PROT_READ | PROT_WRITE, MAP_SHARED,fbfd, 0);
  if ((int)fbp == -1) {
    printf("Error: failed to map framebuffer device to memory.\n");
    exit(4);
  }
  printf("The framebuffer device was mapped to memory successfully.\n");


  x = 100; y = 100; /* Where we are going to put the pixel */
  int pinc = vinfo.bits_per_pixel / 8;
#define FB_OFF(fbx,fby) ((fbx+vinfo.xoffset)*pinc+(fby+vinfo.yoffset)*finfo.line_length)
  /* Figure out where in memory to put the pixel */
//  location = (x+vinfo.xoffset) * (vinfo.bits_per_pixel/8) + (y+vinfo.yoffset) * finfo.line_length;

  memset( fbp, 255, finfo.smem_len );
  for (int fr= 0;fr <256;fr++) {
	for (int yy = 0; yy<256;yy++)
  	for(count = 1 ;count < 256 ;count++)
    {
      location = FB_OFF(yy,count);
      *(fbp + location) = yy;    /* Some blue */
      *(fbp + location +3) = count; /* A little green */
      *(fbp + location  + 1) = fr;//0count; /* A lot of red */
      *(fbp + location  + 2) = count; /* No transparency */
      location += 4;
    }
 /* if (ioctl(fbfd, MSMFB_DISPLAY_COMMIT, &commit)) {
    printf("Error writing commit information.\n");
    exit(3);
  }*/
  if (ioctl(fbfd, FBIOPUT_VSCREENINFO, &vinfo)) {
    printf("Error writing variable information.\n");
    exit(3);
  }
    usleep(1000);
  }
sleep(10);
  munmap(fbp, finfo.smem_len);
  close(fbfd);
  return 0;
}
