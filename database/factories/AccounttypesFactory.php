<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Accounttypes;
use App\Model\Accountclass;
use Faker\Generator as Faker;

$factory->define(Accounttypes::class, function (Faker $faker) use ($factory) {
    return [
        'AccountTypesName' => $faker->unique()->name,
        'Window' => $factory->create(Accountclass::class)->id,
    ];
});
