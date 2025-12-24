#ifndef KALMAN_FILTER_H
#define KALMAN_FILTER_H

namespace Sensors {
    /**
     * Состояние фильтра Калмана
     */
    struct KalmanState {
        float q, r, x, p, k;
    };

    /**
     * Обновление фильтра Калмана
     */
    float kalmanUpdate(KalmanState* state, float measurement) {
        state->p = state->p + state->q;
        state->k = state->p / (state->p + state->r);
        state->x = state->x + state->k * (measurement - state->x);
        state->p = (1 - state->k) * state->p;
        return state->x;
    }
}

#endif