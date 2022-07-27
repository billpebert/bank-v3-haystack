<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Accountclass;
use Faker\Generator as Faker;

$factory->define(Accountclass::class, function (Faker $faker) {
    return [
        'AccountClass' => $faker->unique()->name
    ];
});
