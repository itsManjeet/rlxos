/*
 * Copyright (c) 2025 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package pool

import (
	"log"
	"sync"

	"rlxos.dev/pkg/pool/job"
)

type Pool struct {
	workers  int
	jobQueue chan job.Job
	wg       sync.WaitGroup
	once     sync.Once
	stop     chan struct{}
}

func CreatePool(count int) *Pool {
	return &Pool{
		jobQueue: make(chan job.Job, 50),
		workers:  count,
		stop:     make(chan struct{}),
	}
}

func (p *Pool) Start() {
	for i := 0; i < p.workers; i++ {
		go p.work(i)
	}
}

func (p *Pool) work(i int) {
	for {
		select {
		case job := <-p.jobQueue:
			log.Printf("[WORKER %d] Processing job %v\n", i, job.Id())
			job.Do()
			p.wg.Done()
		case <-p.stop:
			return
		}
	}
}

func (p *Pool) Submit(j job.Job) {
	p.wg.Add(1)
	p.jobQueue <- j
}

func (p *Pool) Wait() {
	p.wg.Wait()
}

func (p *Pool) Shutdown() {
	p.once.Do(func() {
		p.Wait()
		close(p.stop)
	})
}
