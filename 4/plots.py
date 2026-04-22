import re
import matplotlib.pyplot as plt
import numpy as np

def parse_champsim_results(file_path):
    hit_rates = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            
            blocks = content.split('----------------------------------------')
            
            for block in blocks:
                access_match = re.search(r'ACCESS:\s+(\d+)', block)
                hit_match = re.search(r'HIT:\s+(\d+)', block)
                
                if access_match and hit_match:
                    access = int(access_match.group(1))
                    hit = int(hit_match.group(1))
                    
                    print(f"hit: {hit}, access: {access}")
                    
                    hit_rate = hit / access
                    hit_rates.append(hit_rate)
                        
    except FileNotFoundError:
        print(f"Incorrect path '{file_path}'.")
        return []

    return hit_rates

cache_labels = ["128K", "256K", "512K(8w)", "512K(16w)", "1024K"]

def plot_cache_data(data_list, title, filename):
    lru = data_list[0:5]
    ship = data_list[5:10]
    spp = data_list[10:15]

    plt.figure(figsize=(10, 6))
    plt.plot(cache_labels, lru, marker='o', label='LRU (No Prefetch)')
    plt.plot(cache_labels, ship, marker='s', label='SHIP (No Prefetch)')
    plt.plot(cache_labels, spp, marker='^', label='SHIP + SPP Prefetcher')

    plt.title(title)
    plt.xlabel('Размер L2 кэша')
    plt.ylabel('L2 Hit Rate')
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.savefig(filename)
    plt.show()
    
bwaves_filename = "./results/bwaves_results.txt"
gobmk_filename = "./results/gobmk_results.txt"
x264_filename = "./results/x264_results.txt"


bwaves_hit_rates = parse_champsim_results(bwaves_filename)
gobmk_hit_rates = parse_champsim_results(gobmk_filename)
x264_hit_rates = parse_champsim_results(x264_filename)

def calculate_geomean(rates_lists):
    arr = np.array(rates_lists)
    return np.prod(arr, axis=0)**(1/3)

geomean_results = calculate_geomean([bwaves_hit_rates, gobmk_hit_rates, x264_hit_rates])

lru_all = geomean_results[0:5]
ship_no_all = geomean_results[5:10]
ship_spp_all = geomean_results[10:15]

plot_cache_data(geomean_results, 'Сравнение политик замещения и префетчинга L2 кэша', 'results/geomean_graph.png')

plot_cache_data(bwaves_hit_rates, 'Результаты для трассы: BWAVES', 'results/bwaves_graph.png')

plot_cache_data(gobmk_hit_rates, 'Результаты для трассы: GOBMK', 'results/gobmk_graph.png')

plot_cache_data(x264_hit_rates, 'Результаты для трассы: X264', 'results/x264_graph.png')