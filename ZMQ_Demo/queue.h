/*
 * =====================================================================================
 *
 *       Filename:  queue.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  05/01/14 18:14:27
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Andy (gk), andy_y_li@163.com
 *        Company:  RD
 *
 * =====================================================================================
 */

#ifndef _QUEUE_H
#define _QUEUE_H

// define by user
#define MAX_QSIZE (1024 * 16)

typedef struct {
    char *data;
    ssize_t length;
}Item;
//
typedef struct {
    //char *data[MAX_QSIZE];
    Item item[MAX_QSIZE];
    int front;
    int rear;
    int len;
}Queue;

void createQueue(Queue *pq);
int qIsFull(Queue *pq);
int qIsEmpty(Queue *pq);
int queue_length(Queue *pq);
int enItem(Queue *pq,const char *item, ssize_t length);
int deItem(Queue *pq,char **pitem);
void freeData(Queue *pq);

#endif // #ifndef _QUEUE0_H

